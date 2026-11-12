// SPDX-License-Identifier: Apache-2.0
#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>

void uart_init(uint32_t baud_div);
void uart_putc(char c);
void uart_puts(const char *str);
void uart_printf(const char *fmt, ...);

#endif

