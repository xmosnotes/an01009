// Copyright 2023-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef _XUA_CONF_H_
#define _XUA_CONF_H_

/*
 * Device configuration option defines to override default defines found lib_xua/api/xua_conf_defaults.h
 *
 * Build can be customised but changing and adding defines here
 *
 * Note, we check if they are already defined in CMakeLists.txt
 */

/*** Defines relating to basic functionality ***/

/*** Defines relating to channel counts ***/

#define I2S_CHANS_DAC      (2)
#define I2S_CHANS_ADC      (0)
#define XUA_PWM_CHANNELS   (0)

/* Number of USB streaming channels - by default calculate by counting audio interfaces */
#ifndef NUM_USB_CHAN_IN
#define NUM_USB_CHAN_IN    (0)  /* Device to Host */
#endif

#ifndef NUM_USB_CHAN_OUT
#define NUM_USB_CHAN_OUT   (2)  /* Host to Device */
#endif

/*** Defines relating to audio frequencies ***/
/* Master clock defines (in Hz) */
#ifndef MCLK_441
#define MCLK_441           (512*44100)   /* 44.1, 88.2 etc */
#endif

#ifndef MCLK_48
#define MCLK_48            (512*48000)   /* 48, 96 etc */
#endif

/* Maximum frequency device runs at */
#ifndef MAX_FREQ
#define MAX_FREQ           (192000)
#endif

/* Minimum frequency device runs at */
#ifndef MIN_FREQ
#define MIN_FREQ           (48000)
#endif

#ifndef LOW_POWER_ENABLE
#define LOW_POWER_ENABLE   (0)
#endif

#ifndef AUDIO_CLASS
#define AUDIO_CLASS        (2)
#endif

#define XUA_USE_SW_PLL     (0)
#define XUA_DFU_EN		   (0)

/*** Defines relating to feature placement regarding tiles ***/
#define XUD_TILE           (1)
#define AUDIO_IO_TILE      (1)

/*** Defines relating to USB descriptor strings and ID's ***/
#define VENDOR_ID          (0x20B1) /* XMOS VID */
#define PID_AUDIO_2        (0x0018)
#define PID_AUDIO_1        (0x0017)
#define PRODUCT_STR_A2     "XMOS xCORE.ai (UAC2.0)"
#define PRODUCT_STR_A1     "XMOS xCORE.ai (UAC1.0)"

#include "user_main.h"

#endif // _XUA_CONF_H_
