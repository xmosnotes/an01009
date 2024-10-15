#ifndef USER_MAIN_H
#define USER_MAIN_H

#ifdef __XC__

#include <xs1.h>
#include <platform.h>

extern void power_down();

#define USER_MAIN_CORES \
    on tile[0]: {       \
        power_down();   \
    }

#endif
#endif
