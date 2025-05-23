// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#include <print.h>

#include "xua.h"
#include "xk_audio_316_mc_ab/board.h"
extern "C" {
    #include "sw_pll.h"
}
#include "power_down.h"

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

unsafe chanend g_c_board_ctrl;

/* Board setup for XU316 MC Audio (1v1). Called from tile[0] */
/* Provides "remote" access to the "ctrl" port on tile[0] */
[[combinable]]
void board_ctrl(chanend c_board_ctrl)
{
    int enable;
    xk_audio_316_mc_ab_board_setup(board_config);

    while(1)
    {
        select
        {
            case c_board_ctrl :> enable:

                if(enable)
                    xk_audio_316_mc_ab_board_setup(board_config);
                else
                    xk_audio_316_mc_ab_AudioHwShutdown();
                break;
        }
    }
}

/* Configures the external audio hardware at startup. Called from tile[1] */
void AudioHwInit()
{
    if(LOW_POWER_ENABLE){
        power_up_tile(0);
    }
    printstr("AudioHwInit\n");
    unsafe{
        /* Wait until global is set */
        while(!(unsigned) i_i2c_client);
        xk_audio_316_mc_ab_AudioHwInit((client interface i2c_master_if)i_i2c_client, board_config);
    }
    if(LOW_POWER_ENABLE){
        power_down_tile(0);
    }
}

/* Configures the external audio hardware when not streaming. Called from tile[1] */
void AudioHwShutdown()
{
    /* First need to bring switch frequency up before we access PLL registers if powered down */
    if(LOW_POWER_ENABLE){
        power_up_tile(0);
    }
    printstr("AudioHwShutdown\n");
    sw_pll_fixed_clock(0);
    if(LOW_POWER_ENABLE){
        power_down_tile(0);
    }
}

/* Configures the external audio hardware for the required sample frequency. Called from tile[1] */
void AudioHwConfig(unsigned samFreq, unsigned mClk, unsigned dsdMode, unsigned sampRes_DAC, unsigned sampRes_ADC)
{
    if(LOW_POWER_ENABLE){
        power_up_tile(0);
    }
    printstr("AudioHwConfig ");printintln(samFreq);
    unsafe {
        xk_audio_316_mc_ab_AudioHwConfig((client interface i2c_master_if)i_i2c_client, board_config, samFreq, mClk, dsdMode, sampRes_DAC, sampRes_ADC);
    }
    if(LOW_POWER_ENABLE){
        power_down_tile(0);
    }
}
