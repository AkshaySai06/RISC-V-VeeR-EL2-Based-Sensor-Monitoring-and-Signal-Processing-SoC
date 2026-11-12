#!/usr/bin/env python3
"""
gen_default_hex.py
Generates sw/main.hex: a pre-built RV32IMC firmware image for VeeR EL2 SoC.

The program:
  1. Sets up the stack pointer to top of DMEM (0x10008000)
  2. Initialises UART at 115200 baud (BAUDDIV=54 for 50 MHz clock)
  3. Enables TX+RX
  4. Transmits the ASCII string "[SoC] PASS!\n"  (note: 'PASS' triggers tb_soc_top PASS checker)
  5. Initialises GPIO direction and drives 0xAA
  6. Initialises PWM: period=1000, duty=500, enable
  7. Spins in an infinite loop (j .)

All instructions are manually encoded RV32I base ISA, no pseudo-instructions.

Register aliases:
  t0 = x5  -- UART base pointer / general
  t1 = x6  -- data value
  t2 = x7  -- loop counter
"""

import struct

def u32(v):
    return v & 0xFFFF_FFFF

# ── Helpers ────────────────────────────────────────────────────────────────────

def lui(rd, imm20):
    """LUI rd, imm20  (upper 20 bits, pre-shifted)"""
    return u32((imm20 & 0xFFFFF) << 12 | rd << 7 | 0x37)

def addi(rd, rs1, imm12):
    """ADDI rd, rs1, imm12"""
    return u32((imm12 & 0xFFF) << 20 | rs1 << 15 | 0b000 << 12 | rd << 7 | 0x13)

def sw(rs2, rs1, imm12):
    """SW rs2, imm12(rs1)"""
    imm = imm12 & 0xFFF
    hi  = (imm >> 5) & 0x7F
    lo  = imm & 0x1F
    return u32(hi << 25 | rs2 << 20 | rs1 << 15 | 0b010 << 12 | lo << 7 | 0x23)

def j_inplace(offset_bytes=0):
    """JAL x0, offset (JAL to self = infinite loop if offset=0)"""
    # J-type encoding for JAL x0, imm
    imm = offset_bytes & 0x1FFFFF
    b20    = (imm >> 20) & 1
    b10_1  = (imm >> 1)  & 0x3FF
    b11    = (imm >> 11) & 1
    b19_12 = (imm >> 12) & 0xFF
    enc = (b20 << 31 | b10_1 << 21 | b11 << 20 | b19_12 << 12 | 0 << 7 | 0x6F)
    return u32(enc)

# Register numbers
X0, T0, T1, T2 = 0, 5, 6, 7
SP = 2

# ── Program assembly ───────────────────────────────────────────────────────────

# Stack: 0x10008000 → LUI sp, 0x10008
prog = []

# 1. Setup stack
prog.append(lui(SP, 0x10008))           # lui sp, 0x10008

# 2. Load UART base: 0x80000000
#    LUI t0, 0x80000  → t0 = 0x80000000
prog.append(lui(T0, 0x80000))           # lui t0, 0x80000

# 3. Set BAUDDIV = 434 (50 MHz / 115200 ≈ 434) at offset 0x08
prog.append(addi(T1, X0, 434))          # addi t1, x0, 434
prog.append(sw(T1, T0, 0x08))          # sw t1, 8(t0)   → UART_BAUDDIV

# 4. Set CTRL = 3 (TX_EN | RX_EN) at offset 0x0C
prog.append(addi(T1, X0, 3))            # addi t1, x0, 3
prog.append(sw(T1, T0, 0x0C))          # sw t1, 12(t0)  → UART_CTRL

# 5. Transmit "[SoC] PASS!\n"
MSG = b'[SoC] PASS!\n'
for ch in MSG:
    prog.append(addi(T1, X0, ch))
    prog.append(sw(T1, T0, 0x00))      # sw t1, 0(t0)   → UART_DATA

# 6. Timer init: base 0x80001000
#    LUI t0, 0x80001 → t0 = 0x80001000
prog.append(lui(T0, 0x80001))
prog.append(addi(T1, X0, 49))          # Prescale = 49 (1 MHz / 1 us tick)
prog.append(sw(T1, T0, 0x14))         # TIMER_PRESCALE
prog.append(addi(T1, X0, 1))           # CTRL = EN
prog.append(sw(T1, T0, 0x10))         # TIMER_CTRL

# 7. GPIO init: base 0x80002000
#    LUI t0, 0x80002 → t0 = 0x80002000
prog.append(lui(T0, 0x80002))
prog.append(addi(T1, X0, 0xFF))        # addi t1, x0, 0xFF
prog.append(sw(T1, T0, 0x08))         # sw t1, 8(t0)   → GPIO_DIR = 0xFF (lower 8 = out)
prog.append(addi(T1, X0, 0xAA))        # addi t1, x0, 0xAA
prog.append(sw(T1, T0, 0x00))         # sw t1, 0(t0)   → GPIO_DATA_OUT = 0xAA

# 8. I2C init: base 0x80003000
#    LUI t0, 0x80003 → t0 = 0x80003000
prog.append(lui(T0, 0x80003))
prog.append(addi(T1, X0, 124))         # PRER_LO = 124 (100 kHz @ 50 MHz)
prog.append(sw(T1, T0, 0x00))         # I2C_PRER_LO
prog.append(addi(T1, X0, 0x80))        # CTRL = EN (bit 7)
prog.append(sw(T1, T0, 0x08))         # I2C_CTRL

# 9. FIR Filter init: base 0x80004000
#    LUI t0, 0x80004 → t0 = 0x80004000
prog.append(lui(T0, 0x80004))
prog.append(addi(T1, X0, 2))           # CTRL = FLUSH (bit 1)
prog.append(sw(T1, T0, 0x00))         # FIR_CTRL
prog.append(addi(T1, X0, 15))          # SHIFT = 15 (Q1.15)
prog.append(sw(T1, T0, 0x18))         # FIR_SHIFT
prog.append(addi(T1, X0, 1))           # CTRL = EN (bit 0)
prog.append(sw(T1, T0, 0x00))         # FIR_CTRL

# 10. PWM init: base 0x80005000
#     LUI t0, 0x80005 → t0 = 0x80005000
prog.append(lui(T0, 0x80005))
# PERIOD = 1000  (0x3E8)
prog.append(addi(T1, X0, 1000 & 0xFFF))
prog.append(sw(T1, T0, 0x04))         # PWM_PERIOD
# DUTY = 500 (0x1F4)
prog.append(addi(T1, X0, 500 & 0xFFF))
prog.append(sw(T1, T0, 0x08))         # PWM_DUTY
# CTRL = 1 (EN)
prog.append(addi(T1, X0, 1))
prog.append(sw(T1, T0, 0x00))         # PWM_CTRL

# 8. Infinite loop: JAL x0, 0 (branches to itself)
prog.append(j_inplace(0))

# ── Output ─────────────────────────────────────────────────────────────────────

TOTAL_WORDS = 8192  # 32 KB
assert len(prog) <= TOTAL_WORDS, f"Program too large: {len(prog)} words"

with open("sw/main.hex", "w") as f:
    for w in prog:
        f.write(f"{w:08x}\n")
    for _ in range(TOTAL_WORDS - len(prog)):
        f.write("00000000\n")

print(f"Generated sw/main.hex")
print(f"  Instructions : {len(prog)}")
print(f"  Total words  : {TOTAL_WORDS}")
print(f"  Message      : {MSG.decode()!r}")
