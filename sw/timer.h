// SPDX-License-Identifier: Apache-2.0
#ifndef _TIMER_H_
#define _TIMER_H_

#include <stdint.h>

void timer_init(uint32_t prescale);
uint64_t timer_now(void);
void timer_set_cmp(uint64_t cmp);
void timer_wait_us(uint32_t us);

#endif

