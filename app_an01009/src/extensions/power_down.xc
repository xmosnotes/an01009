#include <platform.h>

//on tile[0]: port oneG = XS1_PORT_1G;

void power_down() {
    return;
//    oneG <: 1;
    write_node_config_reg(tile[0], 7, 4);
    write_tile_config_reg(tile[0], 6, 0x80000000);
    setps(0x020b, 0x10);
}
