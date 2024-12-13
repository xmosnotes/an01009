#include <platform.h>

void power_down()
{
    // Give the software 10 seconds to start up, then apply power optimisations below.
    timer tmr;
    int t;
    tmr :> t;
    tmr when timerafter(t+1000000000) :> void;

    // Reduce switch clock frequency
    write_node_config_reg(tile[0], XS1_SSWITCH_CLK_DIVIDER_NUM, 4);

	// Reduce core 0 clock frequency (to 9 MHz)
    // Note, to completely disable, use:
    // write_tile_config_reg(tile[0], XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, 0x80000000);
    write_tile_config_reg(tile[0], XS1_PSWITCH_PLL_CLK_DIVIDER_NUM, 0x00000040);
    setps(XS1_PS_XCORE_CTRL0, 0x10);
}
