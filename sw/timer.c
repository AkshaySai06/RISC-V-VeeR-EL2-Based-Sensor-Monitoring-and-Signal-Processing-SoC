// SPDX-License-Identifier: Apache-2.0
#include "timer.h"
#include "soc.h"

void timer_init(uint32_t prescale) {
    TIMER_REG_PRESCALE = prescale;
    TIMER_REG_CTRL     = TIMER_CTRL_EN;
}

// 64-bit atomic read retry loop per Section 8.5
uint64_t timer_now(void) {
    uint32_t hi1, lo, hi2;
    do {
        hi1 = TIMER_REG_MTIME_HI;
        lo  = TIMER_REG_MTIME_LO;
        hi2 = TIMER_REG_MTIME_HI;
    } while (hi1 != hi2);
    return (((uint64_t)hi1) << 32) | lo;
}

// 64-bit safe write sequence per Section 8.5
void timer_set_cmp(uint64_t cmp) {
    TIMER_REG_MTIMECMP_LO = 0xFFFFFFFFUL;
    TIMER_REG_MTIMECMP_HI = (uint32_t)(cmp >> 32);
    TIMER_REG_MTIMECMP_LO = (uint32_t)(cmp & 0xFFFFFFFFUL);
}

void timer_wait_us(uint32_t us) {
    uint64_t start = timer_now();
    while ((timer_now() - start) < (uint64_t)us);
}

