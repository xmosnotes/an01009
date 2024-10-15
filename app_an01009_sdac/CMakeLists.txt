cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_an02020)

set(APP_HW_TARGET xk-small.xn)

# Use sw_usb_audio deps and add lib_awe
set(APP_DEPENDENT_MODULES "lib_sigma_delta"
                          "lib_xua")

set(APP_PCA_ENABLE ON)

set(APP_COMPILER_FLAGS                          -fcomment-asm
                                                -O3
                                                -report
                                                -lquadflash
                                                -g
                                                -DUSB_TILE=tile[1]
                                                -DXUA_QUAD_SPI_FLASH=1
                                                )

set(APP_INCLUDES    src
                    src/core
                    src/extensions
                    )

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

XMOS_REGISTER_APP()
