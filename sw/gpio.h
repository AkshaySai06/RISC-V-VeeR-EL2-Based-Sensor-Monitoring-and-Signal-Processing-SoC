// SPDX-License-Identifier: Apache-2.0
#ifndef _GPIO_H_
#define _GPIO_H_

#include <stdint.h>

void     gpio_set_dir(uint16_t dir);
void     gpio_write(uint16_t val);
uint16_t gpio_read(void);
void     gpio_set_irq_mask(uint16_t mask);
void     gpio_set_irq_edge(uint16_t edge);
uint16_t gpio_get_irq_stat(void);
void     gpio_clear_irq(uint16_t mask);

#endif // _GPIO_H_
