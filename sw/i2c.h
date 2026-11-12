// SPDX-License-Identifier: Apache-2.0
#ifndef _I2C_H_
#define _I2C_H_

#include <stdint.h>

void i2c_init(uint16_t prescaler);
int i2c_write_byte(uint8_t data, uint8_t is_start, uint8_t is_stop);
uint8_t i2c_read_byte(uint8_t send_ack, uint8_t is_stop);
int16_t i2c_read_sensor(uint8_t dev_addr, uint8_t reg_addr);

#endif

