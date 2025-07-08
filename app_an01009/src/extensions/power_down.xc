// Copyright 2024-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#define DEBUG_UNIT AN01009_POWER_DOWN
#include "debug_print.h"
#define XASSERT_UNIT AN01009_POWER_DOWN
#include "xassert.h"
#include "power_down.h"
#include "audiohw_shared.h"

static void switch_power_down(void)
{
    write_node_config_reg(tile[0], XS1_SSWITCH_CLK_DIVIDER_NUM, (LP_SWITCH_DIV - 1));
}

static void switch_power_up(void)
{
    write_node_config_reg(tile[0], XS1_SSWITCH_CLK_DIVIDER_NUM, (1 - 1)); // Divide by 1
}

void set_core_clock_divider(tileref t, unsigned div)
{
    write_pswitch_reg(get_tile_id(t), XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, div - 1);
}

/* Called from main() on each tile - see user_main.h */
void enable_core_divider(void)
{
    // First ensure we have initialised core divider to /1 so no nasty surprises when enabling the divider
    if(get_local_tile_id() == get_tile_id(tile[0]))
    {
        set_core_clock_divider(tile[0], 1);
    }
    else if (get_local_tile_id() == get_tile_id(tile[1]))
    {
        set_core_clock_divider(tile[1], 1);
    }

    unsigned val = getps(XS1_PS_XCORE_CTRL0);
    setps(XS1_PS_XCORE_CTRL0, val | (1 << 4)); // Set enable divider bit
}

void disable_core_clock(tileref t)
{
    write_tile_config_reg(t, XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, 0x80000000);
}

void power_down_tile_and_switch(int t)
{
    switch_power_down();
    // Reduce tile 0 clock frequency
    set_core_clock_divider(tile[t], LP_XCORE_DIV);
    // Note, to completely disable, use disable_core_clock(). We need I2C active in this example so not possible
}

void power_up_tile(int t)
{
    // Use divide by 1 for switch and unused tile
    switch_power_up();
    set_core_clock_divider(tile[t], 1);
}

// Whole chip power down VCO @ 1MHz, output @ 0.125MHz. This sets the VCO to near off power whilst still operating
// R = 24, F = 1, OD = 8
#define PLL_CTL_VCO1_BYPASS  0x93800117 // Don't reset, in bypass, VCO @ 1MHz, output @ 0.125MHz.

unsigned pllCtrlVal = 0; // State for entry/exit to PLL off mode

// May be called from either tile but must be the same tile as pll_bypass_off()
void pll_bypass_on(void) {
    // Grab original setting once only
    if(pllCtrlVal == 0){
        read_sswitch_reg(get_local_tile_id(), XS1_SSWITCH_PLL_CTL_NUM, pllCtrlVal);
    }
    // Enable bypass and power VCO down
    write_sswitch_reg(get_local_tile_id(), XS1_SSWITCH_PLL_CTL_NUM, PLL_CTL_VCO1_BYPASS);
}

// Note this takes up to 500us to resume. Chip will not be clocked until PLL is stable
// May be called from either tile but must be the same tile as pll_bypass_on()
void pll_bypass_off(void) {
    if(pllCtrlVal == 0){
        return; // we haven't done bypass_on yet
    }
    // Set old value stored by pll_bypass_on
    unsigned new_val = pllCtrlVal;
    new_val &= ~0x40000000; // Ensure we wait for PLL lock
    new_val |= 0x80000000; // Do not reset chip on PLL write

    write_sswitch_reg(get_local_tile_id(), XS1_SSWITCH_PLL_CTL_NUM, new_val);
}

#ifndef BYPASS_PLL_DURING_SUSPEND
#define BYPASS_PLL_DURING_SUSPEND  1 // If not set, we just use the clock dividers which not meet suspend power targets
#endif

int g_inExtremeLowPower = 0;    // Belt and braces flag ensures we don't double enter low/high power modes during suspend.
                                // Note, in Debug build we assert if this is not tracked correctly.

/* Called from Endpoint 0 - running on tile[1] in this application*/
void XUA_UserSuspendPowerDown()
{
    if(AN01009_CLOCK_DOWN_CHIP_IN_SUSPEND && ! g_inExtremeLowPower)
    {
        assert(!g_inExtremeLowPower); // Fires in Debug build only!
        debug_printf("powerDown cb start\n");

#if BYPASS_PLL_DURING_SUSPEND
        // First disable the active mode power down dividers for the unused tile[0]
        power_up_tile(0);
        delay_microseconds(500); // Delay is required for pll_bypass to be robust
        pll_bypass_on();
        set_core_clock_divider(tile[0], 10); // More power down 24 -> 2.4
        set_core_clock_divider(tile[1], 10);
        switch_power_down();
#else
        // Clock chip down as much as possible whilst keeping core PLL running
        // Reduce tile[1] clock frequency. Note tile[0] and switch aready prescaled
        set_core_clock_divider(tile[1], LP_XCORE_DIV);
#endif
        send_board_ctrl_cmd(BOARD_CTL_XCORE_VOLTAGE_REDUCE);
        g_inExtremeLowPower = 1;
    }
}

/* Called from Endpoint 0 - running on tile[1] in this application */
void XUA_UserSuspendPowerUp()
{
    if(AN01009_CLOCK_DOWN_CHIP_IN_SUSPEND && g_inExtremeLowPower)
    {
        assert(g_inExtremeLowPower); // Fires in Debug build only!
        send_board_ctrl_cmd(BOARD_CTL_XCORE_VOLTAGE_NOMINAL);
#if BYPASS_PLL_DURING_SUSPEND
        set_core_clock_divider(tile[0], 1); // Clock tile[0] at full rate again
        set_core_clock_divider(tile[1], 1); // Clock tile[1] at full rate again
        pll_bypass_off();                   // Set PLL running at normal rate set by XN file
        if(AN01009_CLOCK_DOWN_SWITCH_AND_UNUSED_TILE)
        {
            power_down_tile_and_switch(0);  // Power down for active mode
        }
#else
        set_core_clock_divider(tile[1], 1); // Clock tile[1] at full rate again
#endif
        g_inExtremeLowPower = 0;
        debug_printf("powerUp cb complete\n");
    }
}

