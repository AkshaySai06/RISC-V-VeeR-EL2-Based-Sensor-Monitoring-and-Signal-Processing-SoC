// SPDX-License-Identifier: Apache-2.0
// SoC Memory Map and Register Definitions per Appendix A of Spec v2.0

#ifndef _SOC_H_
#define _SOC_H_

#include <stdint.h>

// Peripheral Base Addresses
#define UART_BASE         0x80000000UL
#define TIMER_BASE        0x80001000UL
#define GPIO_BASE         0x80002000UL
#define I2C_BASE          0x80003000UL
#define FIR_BASE          0x80004000UL
#define PWM_BASE          0x80005000UL

// Volatile 32-bit MMIO access macro (ensures WSTRB = 4'hF)
#define REG32(addr)       (*(volatile uint32_t *)(uintptr_t)(addr))

// -----------------------------------------------------------------------------
// UART Registers (0x8000_0000)
// -----------------------------------------------------------------------------
#define UART_REG_DATA     REG32(UART_BASE + 0x00) // W: TXDATA, R: RXDATA
#define UART_REG_STATUS   REG32(UART_BASE + 0x04) // R: STATUS
#define UART_REG_BAUDDIV  REG32(UART_BASE + 0x08) // R/W: BAUDDIV
#define UART_REG_CTRL     REG32(UART_BASE + 0x0C) // R/W: CTRL

#define UART_STATUS_TX_FULL    (1 << 0)
#define UART_STATUS_TX_EMPTY   (1 << 1)
#define UART_STATUS_RX_EMPTY   (1 << 2)
#define UART_STATUS_RX_FULL    (1 << 3)
#define UART_STATUS_OVERRUN    (1 << 4)
#define UART_STATUS_FRAME_ERR  (1 << 5)

#define UART_CTRL_TX_EN        (1 << 0)
#define UART_CTRL_RX_EN        (1 << 1)

// -----------------------------------------------------------------------------
// TIMER Registers (0x8000_1000)
// -----------------------------------------------------------------------------
#define TIMER_REG_MTIME_LO     REG32(TIMER_BASE + 0x00)
#define TIMER_REG_MTIME_HI     REG32(TIMER_BASE + 0x04)
#define TIMER_REG_MTIMECMP_LO  REG32(TIMER_BASE + 0x08)
#define TIMER_REG_MTIMECMP_HI  REG32(TIMER_BASE + 0x0C)
#define TIMER_REG_CTRL         REG32(TIMER_BASE + 0x10)
#define TIMER_REG_PRESCALE     REG32(TIMER_BASE + 0x14)

#define TIMER_CTRL_EN          (1 << 0)
#define TIMER_CTRL_IRQ_EN      (1 << 1)

// -----------------------------------------------------------------------------
// GPIO Registers (0x8000_2000)
// -----------------------------------------------------------------------------
#define GPIO_REG_DATA_OUT      REG32(GPIO_BASE + 0x00)
#define GPIO_REG_DATA_IN       REG32(GPIO_BASE + 0x04)
#define GPIO_REG_DIR           REG32(GPIO_BASE + 0x08)
#define GPIO_REG_IRQ_MASK      REG32(GPIO_BASE + 0x0C)
#define GPIO_REG_IRQ_EDGE      REG32(GPIO_BASE + 0x10)
#define GPIO_REG_IRQ_STAT      REG32(GPIO_BASE + 0x14)

// -----------------------------------------------------------------------------
// I2C Registers (0x8000_3000)
// -----------------------------------------------------------------------------
#define I2C_REG_PRER_LO        REG32(I2C_BASE + 0x00)
#define I2C_REG_PRER_HI        REG32(I2C_BASE + 0x04)
#define I2C_REG_CTRL           REG32(I2C_BASE + 0x08)
#define I2C_REG_DATA           REG32(I2C_BASE + 0x0C) // W: TXR, R: RXR
#define I2C_REG_CMD_STAT       REG32(I2C_BASE + 0x10) // W: CMD, R: STAT

#define I2C_CTRL_EN            (1 << 7)
#define I2C_CTRL_IEN           (1 << 6)

#define I2C_CMD_STA            (1 << 7)
#define I2C_CMD_STO            (1 << 6)
#define I2C_CMD_RD             (1 << 5)
#define I2C_CMD_WR             (1 << 4)
#define I2C_CMD_ACK            (1 << 3)
#define I2C_CMD_IACK           (1 << 0)

#define I2C_STAT_RXACK         (1 << 7)
#define I2C_STAT_BUSY          (1 << 6)
#define I2C_STAT_TIP           (1 << 1)
#define I2C_STAT_IF            (1 << 0)

// -----------------------------------------------------------------------------
// FIR Filter Registers (0x8000_4000)
// -----------------------------------------------------------------------------
#define FIR_REG_CTRL           REG32(FIR_BASE + 0x00)
#define FIR_REG_STATUS         REG32(FIR_BASE + 0x04)
#define FIR_REG_DATA_IN        REG32(FIR_BASE + 0x08)
#define FIR_REG_DATA_OUT       REG32(FIR_BASE + 0x0C)
#define FIR_REG_COEF_ADDR      REG32(FIR_BASE + 0x10)
#define FIR_REG_COEF_DATA      REG32(FIR_BASE + 0x14)
#define FIR_REG_SHIFT          REG32(FIR_BASE + 0x18)
#define FIR_REG_TAPS           REG32(FIR_BASE + 0x1C)

#define FIR_CTRL_EN            (1 << 0)
#define FIR_CTRL_FLUSH         (1 << 1)
#define FIR_CTRL_IRQ_EN        (1 << 2)

#define FIR_STATUS_IDLE        (1 << 0)
#define FIR_STATUS_DONE        (1 << 1)
#define FIR_STATUS_BUSY        (1 << 2)
#define FIR_STATUS_SAT         (1 << 3)

// -----------------------------------------------------------------------------
// PWM Registers (0x8000_5000)
// -----------------------------------------------------------------------------
#define PWM_REG_CTRL           REG32(PWM_BASE + 0x00)
#define PWM_REG_PERIOD         REG32(PWM_BASE + 0x04)
#define PWM_REG_DUTY           REG32(PWM_BASE + 0x08)
#define PWM_REG_PRESCALE       REG32(PWM_BASE + 0x0C)
#define PWM_REG_COUNT          REG32(PWM_BASE + 0x10)
#define PWM_REG_STATUS         REG32(PWM_BASE + 0x14)

#define PWM_CTRL_EN            (1 << 0)
#define PWM_CTRL_POL           (1 << 1)
#define PWM_CTRL_IRQ_EN        (1 << 2)
#define PWM_CTRL_FORCE         (1 << 3)

#endif // _SOC_H_

