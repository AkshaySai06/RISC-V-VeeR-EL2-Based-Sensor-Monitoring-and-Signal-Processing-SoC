// SPDX-License-Identifier: Apache-2.0
#ifndef _PWM_H_
#define _PWM_H_

#include <stdint.h>

void pwm_init(uint16_t period, uint16_t prescale, uint8_t pol);
void pwm_set_duty(uint16_t duty);

#endif

