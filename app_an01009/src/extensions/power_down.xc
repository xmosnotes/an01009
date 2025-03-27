// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>

void power_down()
{
    // Give the software 10 seconds to start up, then apply power optimisations below.
    delay_seconds(10);

    // Reduce switch clock frequency
    write_node_config_reg(tile[0], XS1_SSWITCH_CLK_DIVIDER_NUM, 8);

	// Reduce core 0 clock frequency (to 9 MHz)
    write_tile_config_reg(tile[0], XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, 0x00000040);
    // Note, to completely disable, use:
    // write_tile_config_reg(tile[0], XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, 0x80000000);

    // Enable the clock divider
    setps(XS1_PS_XCORE_CTRL0, 1 << 4);
}
