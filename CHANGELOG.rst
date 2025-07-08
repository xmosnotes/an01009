an01009 change log
==================

2.2.0
-----

  * ADDED:   Support for power down of audio subsystem when device is enumerated
    but host isn't streaming
  * ADDED:   Support for power down of xcore and audio subystem during USB
    suspend
  * ADDED:   Documentation and code for setting USB bMaxPower

  * Changes to dependencies:

    - lib_board_support: 1.2.2 -> 1.3.0

    - lib_sw_pll: 2.3.1 -> 2.4.0

    - lib_xua: 5.0.0 -> 5.1.0

    - lib_xud: 2.4.0 -> 3.0.1

2.1.0
-----

  * ADDED:   Event driven buffer for further power reduction
  * ADDED:   Build configurations for standard and low power
  * FIXED:   DC-DC efficiency calculation error resulting in too high power
    numbers

  * Changes to dependencies:

    - lib_board_support: 1.1.0 -> 1.2.2

    - lib_i2c: 6.3.0 -> 6.4.0

2.0.0
-----

  * CHANGED: Updated for xcore.ai

  * Changes to dependencies:

    - lib_adat: Added dependency 2.0.1

    - lib_board_support: Added dependency 1.1.0

    - lib_i2c: Added dependency 6.3.0

    - lib_locks: Added dependency 2.3.1

    - lib_logging: Added dependency 3.3.1

    - lib_mic_array: Added dependency 5.5.0

    - lib_spdif: Added dependency 6.2.1

    - lib_sw_pll: Added dependency 2.3.1

    - lib_xassert: Added dependency 4.3.1

    - lib_xcore_math: Added dependency 2.4.0

    - lib_xua: Added dependency 5.0.0

    - lib_xud: Added dependency 2.4.0

1.0.0
-----

  * Initial release

