# SPDX-License-Identifier: Apache-2.0
# Startup Assembly Code for VeeR EL2 SoC (crt0.S)
# Sets sp, zeroes .bss, copies .data, and calls main()

.section .text.init
.global _start
.type _start, @function

_start:
    # 0. Configure VeeR EL2 Memory Region Access Control (MRAC, CSR 0x7c0)
    # Region 0 (0x0...): Cacheable (2'b01)
    # Region 8 (0x8...): Side-effect / Non-cacheable MMIO (2'b10)
    li t0, 0x00020001
    csrw 0x7c0, t0
    fence
    fence.i

    # 1. Disable interrupts globally
    csrci mstatus, 0x8

    # 2. Initialize stack pointer
    la sp, __stack_top

    # 3. Initialize global pointer (.sdata/.sbss relaxations)
.option push
.option norelax
    la gp, __global_pointer$
.option pop

    # 4. Copy initialized .data section from IMEM to DMEM
    la a0, _sdata
    la a1, _edata
    la a2, _sidata
copy_data_loop:
    bge a0, a1, zero_bss
    lw t0, 0(a2)
    sw t0, 0(a0)
    addi a0, a0, 4
    addi a2, a2, 4
    j copy_data_loop

    # 5. Zero out .bss section in DMEM
zero_bss:
    la a0, _sbss
    la a1, _ebss
zero_bss_loop:
    bge a0, a1, call_main
    sw zero, 0(a0)
    addi a0, a0, 4
    j zero_bss_loop

    # 6. Call main()
call_main:
    call main

    # 7. Loop forever if main returns
hang:
    wfi
    j hang

.size _start, . - _start

