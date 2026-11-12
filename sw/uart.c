// SPDX-License-Identifier: Apache-2.0
#include "uart.h"
#include "soc.h"
#include <stdarg.h>

void uart_init(uint32_t baud_div) {
    UART_REG_BAUDDIV = baud_div;
    UART_REG_CTRL    = UART_CTRL_TX_EN | UART_CTRL_RX_EN;
}

void uart_putc(char c) {
    // Wait while TX FIFO is full
    while (UART_REG_STATUS & UART_STATUS_TX_FULL);
    UART_REG_DATA = (uint32_t)(uint8_t)c;
}

void uart_puts(const char *str) {
    while (*str) {
        if (*str == '\n') uart_putc('\r');
        uart_putc(*str++);
    }
}

static void print_unsigned(uint32_t n, int base) {
    char buf[32];
    int i = 0;
    if (n == 0) {
        uart_putc('0');
        return;
    }
    while (n > 0) {
        int rem = n % base;
        buf[i++] = (rem < 10) ? ('0' + rem) : ('a' + rem - 10);
        n /= base;
    }
    while (--i >= 0) {
        uart_putc(buf[i]);
    }
}

static void print_signed(int32_t n) {
    if (n < 0) {
        uart_putc('-');
        n = -n;
    }
    print_unsigned((uint32_t)n, 10);
}

void uart_printf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    for (const char *p = fmt; *p; p++) {
        if (*p != '%') {
            if (*p == '\n') uart_putc('\r');
            uart_putc(*p);
            continue;
        }

        p++; // Skip '%'
        // Optional width specifiers like %6d or %4u
        while (*p >= '0' && *p <= '9') p++;

        switch (*p) {
            case 'd': {
                int32_t v = va_arg(ap, int32_t);
                print_signed(v);
                break;
            }
            case 'u': {
                uint32_t v = va_arg(ap, uint32_t);
                print_unsigned(v, 10);
                break;
            }
            case 'x':
            case 'X': {
                uint32_t v = va_arg(ap, uint32_t);
                print_unsigned(v, 16);
                break;
            }
            case 's': {
                const char *s = va_arg(ap, const char *);
                uart_puts(s ? s : "(null)");
                break;
            }
            case 'c': {
                char c = (char)va_arg(ap, int);
                uart_putc(c);
                break;
            }
            case '%':
                uart_putc('%');
                break;
            default:
                uart_putc('%');
                uart_putc(*p);
                break;
        }
    }
    va_end(ap);
}

