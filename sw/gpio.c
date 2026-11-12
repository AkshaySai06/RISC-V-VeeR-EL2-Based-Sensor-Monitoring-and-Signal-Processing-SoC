// SPDX-License-Identifier: Apache-2.0
#include "gpio.h"
#include "soc.h"

void gpio_set_dir(uint16_t dir) {
    GPIO_REG_DIR = (uint32_t)dir;
}

void gpio_write(uint16_t val) {
    GPIO_REG_DATA_OUT = (uint32_t)val;
}

uint16_t gpio_read(void) {
    return (uint16_t)(GPIO_REG_DATA_IN & 0xFFFF);
}

void gpio_set_irq_mask(uint16_t mask) {
    GPIO_REG_IRQ_MASK = (uint32_t)mask;
}

void gpio_set_irq_edge(uint16_t edge) {
    GPIO_REG_IRQ_EDGE = (uint32_t)edge;
}

uint16_t gpio_get_irq_stat(void) {
    return (uint16_t)(GPIO_REG_IRQ_STAT & 0xFFFF);
}

void gpio_clear_irq(uint16_t mask) {
    GPIO_REG_IRQ_STAT = (uint32_t)mask;
}
