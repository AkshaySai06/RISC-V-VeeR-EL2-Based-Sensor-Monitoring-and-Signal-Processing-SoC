// SPDX-License-Identifier: Apache-2.0
#ifndef _FIR_H_
#define _FIR_H_

#include <stdint.h>

void fir_init(const int16_t *coeffs, uint8_t shift);
void fir_write(int16_t sample);
int16_t fir_read(void);
uint32_t fir_status(void);

#endif

