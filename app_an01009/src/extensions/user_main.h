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
extern unsafe chanend g_c_board_ctrl;

[[combinable]]
void board_ctrl(chanend c_board_ctrl);


/* Declarations that will be inserted in main.xc from lib_xua */
#define USER_MAIN_DECLARATIONS                                          \
    interface i2c_master_if i2c[1];                                     \
    chan c_board_ctrl;


#define USER_MAIN_CORES                                                 \
    on tile[0]: {                                                       \
        enable_core_divider();                                          \
        [[combine]]                                                     \
        par                                                             \
        {                                                               \
            board_ctrl(c_board_ctrl);                                   \
            i2c_master(i2c, 1, p_scl, p_sda, 100);                      \
        }                                                               \
    }                                                                   \
    on tile[1]: {                                                       \
        enable_core_divider();                                          \
        unsafe                                                          \
        {                                                               \
            i_i2c_client = i2c[0];                                      \
            g_c_board_ctrl = (chanend) c_board_ctrl;                    \
        }                                                               \
    }
#endif // __XC__

#endif // USER_MAIN_H
