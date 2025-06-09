// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef _AUDIO_HW_SHARED_H_
#define _AUDIO_HW_SHARED_H_

#include "xk_audio_316_mc_ab/board.h"
#include "xua.h"


// Commands we can send to the xu316mc board controller task
typedef enum board_ctrl_cmd_t{
    BOARD_CTL_BOARD_SETUP,
    BOARD_CTL_AUDIO_HW_SHUTDOWN,
    BOARD_CTL_XCORE_VOLTAGE_NOMINAL,
    BOARD_CTL_XCORE_VOLTAGE_REDUCE
} board_ctrl_cmd_t;

// Send board command using sw_lock to safely allow use from different threads
void send_board_ctrl_cmd(board_ctrl_cmd_t cmd);

// Board setup server for XU316 MC Audio (1v1). Called from tile[0]
// Provides "remote" access to the "ctrl" port on tile[0]
[[combinable]]
void board_ctrl(chanend c_board_ctrl);

#endif