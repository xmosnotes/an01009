cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_an01009)

set(APP_HW_TARGET xk-small.xn)

# Use sw_usb_audio deps and add lib_awe
set(APP_DEPENDENT_MODULES "lib_xua" "lib_board_support")

set(APP_PCA_ENABLE ON)

set(APP_COMPILER_FLAGS                          -fcomment-asm
                                                -O3
                                                -report
                                                -lquadflash
                                                -g
                                                -DBOARD_SUPPORT_BOARD=XK_AUDIO_316_MC_AB
                                                -DUSB_TILE=tile[1]
                                                -DXUD_CORE_CLOCK=500
                                                -DXUA_QUAD_SPI_FLASH=1
                                                )

set(APP_INCLUDES    src
                    src/core
                    src/extensions
                    )

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

XMOS_REGISTER_APP()
