// Copyright 2023-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef USER_MAIN_H
#define USER_MAIN_H

#ifdef __XC__

#include <xs1.h>
#include <platform.h>
#include "xk_audio_316_mc_ab/board.h"
#include "power_down.h"

/* Board hardware setup */
extern unsafe client interface i2c_master_if i_i2c_client;

extern void board_setup();


#if LOW_POWER_ENABLE
/* Call the clock power down code */
#define POWER_DOWN() power_down_unused_tile()
#else
/* Do nothing */
#define POWER_DOWN()
#endif

/* Declarations that will be inserted in main.xc from lib_xua */
#define USER_MAIN_DECLARATIONS                                          \
    interface i2c_master_if i2c[1];


#define USER_MAIN_CORES                                                 \
    on tile[0]: {                                                       \
        enable_core_divider();                                          \
        board_setup();                                                  \
        POWER_DOWN();                                                   \
        i2c_master(i2c, 1, p_scl, p_sda, 100);                          \
    }                                                                   \
    on tile[1]: {                                                       \
        enable_core_divider();                                          \
        unsafe                                                          \
        {                                                               \
            i_i2c_client = i2c[0];                                      \
        }                                                               \
    }
#endif // __XC__

#endif // USER_MAIN_H
