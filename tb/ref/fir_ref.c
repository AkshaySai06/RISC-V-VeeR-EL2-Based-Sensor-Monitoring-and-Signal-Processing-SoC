// SPDX-License-Identifier: Apache-2.0
// Golden Reference Model for 16-Tap FIR Filter
// Matches the RTL fixed-point Q1.15 bit-accurate arithmetic

#include <stdio.h>
#include <stdint.h>
#include "sw/fir_coeffs.h"

typedef struct {
    int16_t delay_line[FIR_NTAPS];
    int16_t coef[FIR_NTAPS];
    uint8_t shift;
    uint8_t sat_flag;
} fir_filter_t;

void fir_init(fir_filter_t *fir, const int16_t *coeffs, uint8_t shift) {
    for (int i = 0; i < FIR_NTAPS; i++) {
        fir->delay_line[i] = 0;
        fir->coef[i] = coeffs[i];
    }
    fir->shift = shift;
    fir->sat_flag = 0;
}

void fir_flush(fir_filter_t *fir) {
    for (int i = 0; i < FIR_NTAPS; i++) {
        fir->delay_line[i] = 0;
    }
}

int16_t fir_process_sample(fir_filter_t *fir, int16_t sample) {
    // Shift delay line
    for (int i = FIR_NTAPS - 1; i > 0; i--) {
        fir->delay_line[i] = fir->delay_line[i - 1];
    }
    fir->delay_line[0] = sample;

    // Multiply-accumulate in 64-bit to prevent overflow (RTL uses 40-bit)
    int64_t acc = 0;
    for (int k = 0; k < FIR_NTAPS; k++) {
        acc += (int64_t)fir->delay_line[k] * (int64_t)fir->coef[k];
    }

    // Arithmetic right shift
    int64_t shifted = acc >> fir->shift;

    // Saturation clamp [-32768, 32767]
    int16_t out;
    if (shifted > 32767) {
        out = 32767;
        fir->sat_flag = 1;
    } else if (shifted < -32768) {
        out = -32768;
        fir->sat_flag = 1;
    } else {
        out = (int16_t)shifted;
    }

    return out;
}

