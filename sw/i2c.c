// SPDX-License-Identifier: Apache-2.0
#include "i2c.h"
#include "soc.h"

static void i2c_wait_tip(void) {
    while (I2C_REG_CMD_STAT & I2C_STAT_TIP);
}

void i2c_init(uint16_t prescaler) {
    I2C_REG_PRER_LO = prescaler & 0xFF;
    I2C_REG_PRER_HI = (prescaler >> 8) & 0xFF;
    I2C_REG_CTRL    = I2C_CTRL_EN;
}

int i2c_write_byte(uint8_t data, uint8_t is_start, uint8_t is_stop) {
    I2C_REG_DATA = data;
    uint32_t cmd = I2C_CMD_WR;
    if (is_start) cmd |= I2C_CMD_STA;
    if (is_stop)  cmd |= I2C_CMD_STO;
    I2C_REG_CMD_STAT = cmd;
    i2c_wait_tip();
    // Return 0 if ACKed, -1 if NACKed
    return (I2C_REG_CMD_STAT & I2C_STAT_RXACK) ? -1 : 0;
}

uint8_t i2c_read_byte(uint8_t send_ack, uint8_t is_stop) {
    uint32_t cmd = I2C_CMD_RD;
    if (!send_ack) cmd |= I2C_CMD_ACK; // 1 = NACK
    if (is_stop)   cmd |= I2C_CMD_STO;
    I2C_REG_CMD_STAT = cmd;
    i2c_wait_tip();
    return (uint8_t)(I2C_REG_DATA & 0xFF);
}

// Read 2-byte sensor value per Section 8.1.6
int16_t i2c_read_sensor(uint8_t dev_addr, uint8_t reg_addr) {
    // 1. Send device write address
    i2c_write_byte((dev_addr << 1) | 0, 1, 0);
    // 2. Send register address
    i2c_write_byte(reg_addr, 0, 0);
    // 3. Repeated start with device read address
    i2c_write_byte((dev_addr << 1) | 1, 1, 0);
    // 4. Read MSB with ACK
    uint8_t msb = i2c_read_byte(1, 0);
    // 5. Read LSB with NACK and STOP
    uint8_t lsb = i2c_read_byte(0, 1);

    return (int16_t)((msb << 8) | lsb);
}

