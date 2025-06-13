// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef _XUD_CONF_H_
#define _XUD_CONF_H_

#ifndef AN01009_DISABLE_XUD_FAST_MODE
#define AN01009_DISABLE_XUD_FAST_MODE 0
#endif

#if AN01009_DISABLE_XUD_FAST_MODE
// Delete the call to set_thread_fast_mode_on in XUD by defining the built-in as ""
#define __builtin_set_thread_fast()
#endif

#endif
