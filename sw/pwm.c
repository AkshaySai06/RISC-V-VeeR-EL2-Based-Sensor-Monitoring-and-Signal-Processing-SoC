// SPDX-License-Identifier: Apache-2.0
#include "pwm.h"
#include "soc.h"

void pwm_init(uint16_t period, uint16_t prescale, uint8_t pol) {
    PWM_REG_PERIOD   = period;
    PWM_REG_PRESCALE = prescale;
    PWM_REG_DUTY     = 0;
    PWM_REG_CTRL     = PWM_CTRL_EN | (pol ? PWM_CTRL_POL : 0);
}

void pwm_set_duty(uint16_t duty) {
    PWM_REG_DUTY = duty;
}

