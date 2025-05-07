cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_an01009)

set(APP_HW_TARGET xk-audio-316-mc-tile1.xn)

set(APP_DEPENDENT_MODULES "ed-xmos/lib_xua(feature/no_stream_power_simpl)" # TODO changeme when merged/released
                          "lib_board_support(1.2.2)" # TODO this needs bumping too when sw_pll dep is released
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
                            )

set(APP_COMPILER_FLAGS_std  ${COMMON_COMPILER_FLAGS})

set(APP_COMPILER_FLAGS_lp   ${COMMON_COMPILER_FLAGS}
                            -DLOW_POWER_ENABLE=1
                            -DCHAN_BUFF_CTRL=1
                            -DXUD_PRIORITY_HIGH=1
                            -DXUA_LOW_POWER_NON_STREAMING=1
                            )

set(APP_INCLUDES    src
                    src/core
                    src/extensions
                    )

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)

XMOS_REGISTER_APP()
