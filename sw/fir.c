// SPDX-License-Identifier: Apache-2.0
#include "fir.h"
#include "soc.h"

void fir_init(const int16_t *coeffs, uint8_t shift) {
    FIR_REG_CTRL = FIR_CTRL_FLUSH; // Flush delay line
    FIR_REG_SHIFT = shift;

    // Load coefficients
    FIR_REG_COEF_ADDR = 0;
    for (int i = 0; i < 16; i++) {
        FIR_REG_COEF_DATA = (uint32_t)(uint16_t)coeffs[i];
    }

    FIR_REG_CTRL = FIR_CTRL_EN; // Enable filter
}

void fir_write(int16_t sample) {
    FIR_REG_DATA_IN = (uint32_t)(uint16_t)sample;
}

int16_t fir_read(void) {
    return (int16_t)(FIR_REG_DATA_OUT & 0xFFFF);
}

uint32_t fir_status(void) {
    return FIR_REG_STATUS;
}

