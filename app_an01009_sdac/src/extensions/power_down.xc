#include <platform.h>
#include <stdio.h>
#include <stdlib.h>

on tile[0]: port oneG = XS1_PORT_1G;

#define SAMPLES  25

char bt_store[SAMPLES];
char bt2_store[SAMPLES];
char bt3_store[SAMPLES];
int ts[SAMPLES];

void power_down() {
    // Give the software 10 seconds to start.
    // After that, reduce power supply and slow this core and the tile down.
    timer tmr;
    int t;
    tmr :> t;
    tmr when timerafter(t+1000000000) :> void;

//#define power_down
#ifdef power_down
    oneG <: 1;
    write_node_config_reg(tile[0], 7, 4);
//#define kill_tile
#ifdef kill_tile
    write_tile_config_reg(tile[0], 6, 0x80000000);
#else
    write_tile_config_reg(tile[0], 6, 0x00000010);
#endif
    setps(0x020b, 0x10);
#else
    tmr :> t;
    
    for(int i = 0; i < SAMPLES; i++) {
        char bt = 0;
        char bt2 = 0;
        char bt3 = 0;
        for(int j = 0; j < 8; j++) {
            unsigned val;
            read_tile_config_reg(tile[1], 0x60 + j, val);
            bt |= ((val >> 6) & 1) << j;
            bt2 |= ((val >> 7) & 1) << j;
            bt3 |= ((val >> 8) & 1) << j;
        }

        bt_store[i] = bt;
        bt2_store[i] = bt2;
        bt3_store[i] = bt3;
        int tmp;
        tmr :> tmp;
        ts[i] = tmp - t;
    }
    for(int i = 0; i < SAMPLES; i++) {
        printf("%5d WT %2x FS %2x DI %2x\n", ts[i], bt_store[i], bt2_store[i], bt3_store[i]);
    }
    exit(1);
#endif
}
