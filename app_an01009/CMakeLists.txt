cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_an01009)

set(APP_HW_TARGET xk-audio-316-mc-tile1.xn)

set(APP_DEPENDENT_MODULES   "lib_board_support(develop)" # TODO change me when xua merged/released
                             "lib_xua(develop)" # TODO change me when xua merged/released
                            )

set(APP_PCA_ENABLE ON)

set(COMMON_COMPILER_FLAGS   -fcomment-asm
                            -Os
                            -report
                            -lquadflash
                            -g
                            -DBOARD_SUPPORT_BOARD=XK_AUDIO_316_MC_AB
                            -DUSB_TILE=tile[1]
                            -DXUD_CORE_CLOCK=600
                            -DXUA_QUAD_SPI_FLASH=1
                            -DDEBUG_PRINT_ENABLE=1
                            )

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND COMMON_COMPILER_FLAGS
                                        -DXASSERT_ENABLE_ASSERTIONS_AN01009_POWER_DOWN=1
                                        -DDEBUG_PRINT_ENABLE_AN01009_POWER_DOWN=1
                                        -DXASSERT_ENABLE_ASSERTIONS_AN01009_AUDIO_HW=1
                                        -DDEBUG_PRINT_ENABLE_AN01009_AUDIO_HW=1
                               )
    message(STATUS "Debug build - asserts and prints are enabled")
else()
    list(APPEND COMMON_COMPILER_FLAGS
                                        -DXASSERT_DISABLE_ASSERTIONS_AN01009_POWER_DOWN=1
                                        -DXASSERT_DISABLE_DEBUG_AN01009_POWER_DOWN=1
                                        -DXASSERT_DISABLE_ASSERTIONS_AN01009_AUDIO_HW=1
                                        -DXASSERT_DISABLE_DEBUG_AN01009_AUDIO_HW=1
                                 )
endif()

set(APP_COMPILER_FLAGS_std  ${COMMON_COMPILER_FLAGS})

set(APP_COMPILER_FLAGS_lp   ${COMMON_COMPILER_FLAGS}
                            -DAN01009_CLOCK_DOWN_SWITCH_AND_UNUSED_TILE=1
                            -DXUA_LOW_POWER_NON_STREAMING=1
                            -DXUA_CHAN_BUFF_CTRL=1
                            -DAN01009_DISABLE_XUD_FAST_MODE=1
                            -DXUD_PRIORITY_HIGH=1
                            -DAN01009_CLOCK_DOWN_CHIP_IN_SUSPEND=1
                            )

set(APP_COMPILER_FLAGS_lp_fs ${COMMON_COMPILER_FLAGS}
                            -DAN01009_CLOCK_DOWN_SWITCH_AND_UNUSED_TILE=1
                            -DXUA_LOW_POWER_NON_STREAMING=1
                            -DXUA_CHAN_BUFF_CTRL=1
                            -DAN01009_DISABLE_XUD_FAST_MODE=1
                            -DXUD_PRIORITY_HIGH=1
                            -DAN01009_CLOCK_DOWN_CHIP_IN_SUSPEND=1
                            -DXUA_USB_BUS_SPEED=1
                            )

set(APP_INCLUDES    src
                    src/core
                    src/extensions
                    )

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

XMOS_REGISTER_APP()
