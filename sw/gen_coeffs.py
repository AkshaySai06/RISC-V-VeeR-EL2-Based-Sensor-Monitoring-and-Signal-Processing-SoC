#!/usr/bin/env python3
"""
FIR Filter Coefficient Generator
Generates a 16-tap Hamming-windowed low-pass filter with cutoff at 0.1 * Fs.
Normalizes coefficients so sum(|h[k]|) < 1.0 in Q1.15 format.
Outputs C header sw/fir_coeffs.h
"""

import math
import os

def generate_fir_coeffs():
    N = 16 # 16 taps
    fc = 0.1 # Cutoff frequency (normalized to Fs, 0 < fc < 0.5)
    M = N - 1 # Filter order (15)

    # Calculate ideal sinc impulse response
    h_ideal = []
    for n in range(N):
        if n == M / 2:
            h_ideal.append(2.0 * fc)
        else:
            val = math.sin(2.0 * math.pi * fc * (n - M / 2)) / (math.pi * (n - M / 2))
            h_ideal.append(val)

    # Hamming window: w[n] = 0.54 - 0.46 * cos(2*pi*n / M)
    h_win = []
    for n in range(N):
        w = 0.54 - 0.46 * math.cos(2.0 * math.pi * n / M)
        h_win.append(h_ideal[n] * w)

    # Normalize so sum(|h|) < 0.95 (guarantees no overflow in Q1.15 with any 16-bit input)
    sum_abs = sum(abs(x) for x in h_win)
    target_sum = 0.90
    scale = target_sum / sum_abs
    h_norm = [x * scale for x in h_win]

    # Convert to Q1.15 integers (signed 16-bit: -32768 to +32767)
    q15 = []
    for x in h_norm:
        val = int(round(x * 32768.0))
        if val > 32767: val = 32767
        if val < -32768: val = -32768
        q15.append(val)

    # Output C header
    c_lines = [
        "// SPDX-License-Identifier: Apache-2.0",
        "// Automatically generated FIR Filter Coefficients (Q1.15 format)",
        "// 16-tap Hamming-windowed Low-Pass Filter (Cutoff = 0.1 * Fs)",
        "#ifndef _FIR_COEFFS_H_",
        "#define _FIR_COEFFS_H_",
        "",
        "#include <stdint.h>",
        "",
        "#define FIR_NTAPS 16",
        "",
        "static const int16_t fir_coeffs[FIR_NTAPS] = {"
    ]
    for i, c in enumerate(q15):
        comma = "," if i < N - 1 else ""
        c_lines.append(f"    {c:6d}{comma} /* h[{i:2d}] = {h_norm[i]:+0.6f} (0x{(c & 0xFFFF):04X}) */")
    c_lines.append("};")
    c_lines.append("")
    c_lines.append("#endif // _FIR_COEFFS_H_\n")

    os.makedirs("sw", exist_ok=True)
    with open("sw/fir_coeffs.h", "w") as f:
        f.write("\n".join(c_lines))

    print(f"Generated sw/fir_coeffs.h successfully with {N} taps.")
    print("Q1.15 integer coefficients:", q15)

if __name__ == "__main__":
    generate_fir_coeffs()

