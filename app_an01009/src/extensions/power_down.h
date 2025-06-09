// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>


// Divider settings for LP. Note this is the actual division ratio. It is adjusted to the reg val in the below functions.
#define LP_SWITCH_DIV   6
#define LP_XCORE_DIV    40

// This does a read modify write to avoid upsetting other bits in the reg
// This must be called from the tile to be configured
// The core clock divider is initialised to 1 (no division)
void enable_core_divider(void);

// Set xcore processor clock divider from PLL output
void set_core_clock_divider(tileref t, unsigned divider);

// Completely switch off clock to a tile
// May be called from either tile but if switching off own tile, execution will halt in this function
void disable_core_clock(tileref t);

// Turns down core clock on tile[t] and switch clock
// May be called from either tile
void power_down_tile(int t);

// Restores core clock on tile[t] and switch clock
// May be called from either tile
void power_up_tile(int t);

// Sets XTAL to go straight to chip (nominally 24 MHz). Stores current setting for pll_bypass_off()
// VCO is put into lowest power state whilst still responsive to future register writes
// May be called from either tile
void pll_bypass_on(void);

// Restore PLL setting saved from pll_bypass_on()
// Note this takes up to 500us to resume. Chip will not be clocked until PLL is stable
// May be called from either tile
void pll_bypass_off(void);
