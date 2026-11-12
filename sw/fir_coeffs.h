// SPDX-License-Identifier: Apache-2.0
// Automatically generated FIR Filter Coefficients (Q1.15 format)
// 16-tap Hamming-windowed Low-Pass Filter (Cutoff = 0.1 * Fs)
#ifndef _FIR_COEFFS_H_
#define _FIR_COEFFS_H_

#include <stdint.h>

#define FIR_NTAPS 16

static const int16_t fir_coeffs[FIR_NTAPS] = {
       -97, /* h[ 0] = -0.002975 (0xFF9F) */
      -136, /* h[ 1] = -0.004157 (0xFF78) */
      -119, /* h[ 2] = -0.003638 (0xFF89) */
       250, /* h[ 3] = +0.007619 (0x00FA) */
      1242, /* h[ 4] = +0.037908 (0x04DA) */
      2815, /* h[ 5] = +0.085892 (0x0AFF) */
      4496, /* h[ 6] = +0.137193 (0x1190) */
      5591, /* h[ 7] = +0.170618 (0x15D7) */
      5591, /* h[ 8] = +0.170618 (0x15D7) */
      4496, /* h[ 9] = +0.137193 (0x1190) */
      2815, /* h[10] = +0.085892 (0x0AFF) */
      1242, /* h[11] = +0.037908 (0x04DA) */
       250, /* h[12] = +0.007619 (0x00FA) */
      -119, /* h[13] = -0.003638 (0xFF89) */
      -136, /* h[14] = -0.004157 (0xFF78) */
       -97 /* h[15] = -0.002975 (0xFF9F) */
};

#endif // _FIR_COEFFS_H_
