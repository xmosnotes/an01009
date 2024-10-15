#include <platform.h>
#include <stdio.h>

extern in port p_margin;

void power_down() {
    // Give the software 10 seconds to start.
    // After that, reduce power supply and slow this core and the tile down.
    timer tmr;
    int t;
    tmr :> t;
    tmr when timerafter(t+1000000000) :> void;
    
    asm volatile("out res[%0], %1" :: "r" (p_margin), "r" (1));
    write_node_config_reg(tile[0], 7, 4);
//#define kill_tile
#ifdef kill_tile
    write_tile_config_reg(tile[0], 6, 0x80000000);
#else
    write_tile_config_reg(tile[0], 6, 0x00000010);
#endif
    setps(0x020b, 0x10);
}
