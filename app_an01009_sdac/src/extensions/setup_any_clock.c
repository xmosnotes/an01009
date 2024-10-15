// Copyright 2023-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <assert.h>
#include <xs1.h>
#include <xcore/port.h>
#include <xcore/select.h>
#include <xcore/hwtimer.h>

// Function to write the APP_PLL_CTL register in a clean way to ensure reliable operation.
// Need to pass in the tile number and desired register value.
static void set_app_pll (int app_pll_ctl)
{
    int tile = get_local_tile_id();
  // Disable the PLL 
  write_sswitch_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, (app_pll_ctl & 0xF7FFFFFF));
  // Enable the PLL to invoke a reset on the appPLL.
  write_sswitch_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
  // Must write the CTL register twice so that the F and R divider values are captured using a running clock.
  write_sswitch_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
  // Now disable and re-enable the PLL so we get the full 5us reset time with the correct F and R values.
  write_sswitch_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, (app_pll_ctl & 0xF7FFFFFF));
  write_sswitch_reg(tile, XS1_SSWITCH_SS_APP_PLL_CTL_NUM, app_pll_ctl);
  // Wait for PLL to lock.
  delay_microseconds(500);
}

/**
 * Function that tests if the master_clock is present, and if not creates a
 * 24 MHz App PLL clock.
 */
void setup_master_clock(port_t p_master_clock)
{
    int clock_count = 0;
    int val = 0;
    hwtimer_t tmr = hwtimer_alloc();
    int time;
    port_set_trigger_in_equal(p_master_clock, val);
    time = hwtimer_get_time(tmr);
    hwtimer_set_trigger_time(tmr, time + 1000);      // Count master clocks for
                                                     // 100 ref clocks
    SELECT_RES(
        CASE_THEN(p_master_clock, clock_toggled),
        CASE_THEN(tmr, timer_pinged)) {
    clock_toggled:
        (void) port_in(p_master_clock);
        val = !val;
        clock_count++;
        port_set_trigger_in_equal(p_master_clock, val);
        SELECT_CONTINUE_NO_RESET;
    timer_pinged:
        (void) hwtimer_get_time(tmr);
        break;
    }
    hwtimer_free(tmr);
    if (clock_count < 5) {
        // R: 1, divide by 2
        // F: 63, multiply by (63+1)/2 is 32
        // OD: 7, divider by 8
        // VCO = 64 / 2 x 1 / 2 x 24 = 384 MHz
        // out = 384 / 8 = 48 MHz
        // Enable = 1
        // then divide by 2 before outputting to X1D11
        //    bit 28   24   20   16   12    8    4    0
        //    0b0000 1011 1000 0000 0011 1111 0000 0001
        //    0x   0    3    8    0    3    F    0    1
        set_app_pll(0x0B803F01);
        write_sswitch_reg(get_local_tile_id(), XS1_SSWITCH_SS_APP_CLK_DIVIDER_NUM, 0x80000000);
    }
}
