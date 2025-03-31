// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#include "xua.h"
#include "xk_audio_316_mc_ab/board.h"

/* This is the audio hardware setup file. In this case we are bringing in lib_board_support and
   calling the hardware functions provided by that for the XU316 MC Audio (1v1) platform */

static xk_audio_316_mc_ab_config_t board_config =
{
    CLK_FIXED,              // clk_mode
    CODEC_MASTER,           // dac_is_clk_master
    (DEFAULT_FREQ % 22050 == 0) ? MCLK_441 : MCLK_48,     // default_mclk
    0,                      // pll_sync_freq. Ignored in this app.
    XUA_PCM_FORMAT,         // pcm_format, I2S in this case
    XUA_I2S_N_BITS,         // i2s_n_bits. 32b in this case
    I2S_CHANS_PER_FRAME     // i2s_chans_per_frame, 2 for I2S
};

unsafe client interface i2c_master_if i_i2c_client;

/* Board setup for XU316 MC Audio (1v1). Not called from tile[0] */
void board_setup()
{
    xk_audio_316_mc_ab_board_setup(board_config);
}

/* Configures the external audio hardware at startup. Called from tile[1] */
void AudioHwInit()
{
    unsafe{
        /* Wait until global is set */
        while(!(unsigned) i_i2c_client);
        xk_audio_316_mc_ab_AudioHwInit((client interface i2c_master_if)i_i2c_client, board_config);
    }
}

/* Configures the external audio hardware for the required sample frequency. Called from tile[1] */
void AudioHwConfig(unsigned samFreq, unsigned mClk, unsigned dsdMode, unsigned sampRes_DAC, unsigned sampRes_ADC)
{
    unsafe {xk_audio_316_mc_ab_AudioHwConfig((client interface i2c_master_if)i_i2c_client, board_config, samFreq, mClk, dsdMode, sampRes_DAC, sampRes_ADC);}
}
