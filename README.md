CJMCU-8223 board support package
================================

This is a mynewt package for the CJMCU-8223.

The MCU is a NRF51822 with 16KB of RAM and 256KB or FLASH,
there is an external configurable LIS3DH accelerometer

This board is inexpensive but has some shortcomings.

The LED is connected to the external accelerometer,
it cannot be activated from the GPIO alone.

It does not come with the Nordic SoftDevice already
flashed.
