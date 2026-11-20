# -*- coding: utf-8 -*-
"""
sections_ch4_to_ch6.py
Chapters 4, 5, and 6:
- Chapter 4: RISC-V Toolchain Setup Steps (4.1 - 4.6, Listings 4.1 - 4.5)
- Chapter 5: Address Map (5.1 - 5.3, Tables 5.1 - 5.7)
- Chapter 6: Testplan with External / Internal Test Column (6.1 - 6.2, Table 6.1)
"""

from reportlab.platypus import Paragraph, Spacer, Table, TableStyle, PageBreak, Image, HRFlowable, KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from sections_ch1_to_ch3 import make_code_box, make_callout_box

def get_ch4_to_ch6_flowables(styles):
    story = []

    # =============================================================
    # CHAPTER 4: RISC-V TOOLCHAIN SETUP STEPS
    # =============================================================
    story.append(Paragraph("<b>Chapter 4</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>RISC-V TOOLCHAIN SETUP STEPS</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 4.1 Overview of the RISC-V GNU Compiler Toolchain
    story.append(Paragraph("<b>4.1  Overview of the RISC-V GNU Compiler Toolchain</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    tc_intro = (
        "To compile bare-metal C firmware, device drivers, and diagnostic test programs for the VeeR EL2 core, "
        "a cross-compiler targeting the RISC-V architecture is required. The Western Digital VeeR EL2 core implements "
        "the 32-bit RISC-V base integer instruction set (RV32I) augmented with the Standard Extension for Integer "
        "Multiplication and Division (M), Standard Extension for Compressed Instructions (C), and Control/Status Register "
        "instructions (Zicsr). The target architecture string is <b>rv32imc_zicsr</b> and the Application Binary Interface (ABI) "
        "is <b>ilp32</b> (32-bit integer, long, and pointer with software floating-point emulation).<br/><br/>"
        "The official <i>riscv-gnu-toolchain</i> cross-compilation suite generates the required binaries "
        "(riscv64-unknown-elf-gcc, riscv64-unknown-elf-objcopy, riscv64-unknown-elf-objdump), allowing software compiled "
        "on an x86_64 host workstation to execute directly on the simulated VeeR EL2 core."
    )
    story.append(Paragraph(tc_intro, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 4.2 Host System Prerequisites & Dependency Installation
    story.append(Paragraph("<b>4.2  Host System Prerequisites & Dependency Installation</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l41_code = (
        "# --- For Ubuntu / Debian Systems ---\n"
        "sudo apt-get update\n"
        "sudo apt-get install -y autoconf automake autotools-dev curl python3 python3-pip \\\n"
        "    libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \\\n"
        "    gperf libtool patchutils bc zlib1g-dev libexpat-dev libglib2.0-dev git\n\n"
        "# --- For CentOS / RHEL / Rocky Linux 8 Systems (Matching EDA Lab) ---\n"
        "sudo dnf groupinstall -y \"Development Tools\"\n"
        "sudo dnf install -y autoconf automake curl python3 gmp-devel mpfr-devel \\\n"
        "    libmpc-devel gawk bison flex texinfo patchutils expat-devel zlib-devel git"
    )
    story.append(make_code_box("4.1: Host Dependency Installation Commands", l41_code, styles))
    story.append(Spacer(1, 10))

    # 4.3 Sourcing & Cloning the Toolchain Repository
    story.append(Paragraph("<b>4.3  Sourcing & Cloning the Toolchain Repository</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l42_code = (
        "# 1. Create a dedicated tools directory\n"
        "mkdir -p ~/tools && cd ~/tools\n\n"
        "# 2. Clone official repository with recursive submodules (~4.5 GB)\n"
        "git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git\n"
        "cd riscv-gnu-toolchain"
    )
    story.append(make_code_box("4.2: Cloning riscv-gnu-toolchain Submodules", l42_code, styles))
    story.append(Spacer(1, 10))

    # 4.4 Toolchain Configuration for VeeR EL2
    story.append(Paragraph("<b>4.4  Toolchain Configuration for VeeR EL2 (RV32IMC / ILP32)</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l43_code = (
        "# 1. Create target destination directory (/opt/riscv)\n"
        "sudo mkdir -p /opt/riscv\n"
        "sudo chown -R $(whoami):$(whoami) /opt/riscv\n\n"
        "# 2. Configure for bare-metal (Newlib) RV32IMC cross-compilation\n"
        "./configure \\\n"
        "    --prefix=/opt/riscv \\\n"
        "    --with-arch=rv32imc_zicsr \\\n"
        "    --with-abi=ilp32 \\\n"
        "    --enable-multilib"
    )
    story.append(make_code_box("4.3: Configuring Cross-Compiler for RV32IMC Target", l43_code, styles))
    story.append(Spacer(1, 10))

    # 4.5 Compilation, Installation & Environment Configuration
    story.append(Paragraph("<b>4.5  Compilation, Installation & Environment Configuration</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l44_code = (
        "# 1. Build toolchain using parallel cores\n"
        "make -j$(nproc)\n\n"
        "# 2. Export toolchain binaries to user PATH in ~/.bashrc\n"
        "echo 'export RISCV=/opt/riscv' >> ~/.bashrc\n"
        "echo 'export PATH=$RISCV/bin:$PATH' >> ~/.bashrc\n"
        "source ~/.bashrc\n\n"
        "# 3. Verify installation and compiler version\n"
        "riscv64-unknown-elf-gcc --version\n"
        "# Output: riscv64-unknown-elf-gcc (g2ee5e430018) 13.2.0"
    )
    story.append(make_code_box("4.4: Building and Exporting RISC-V Toolchain", l44_code, styles))
    story.append(Spacer(1, 10))

    # 4.6 Bare-Metal Firmware Build Flow & Toolchain Flags
    story.append(Paragraph("<b>4.6  Bare-Metal Firmware Build Flow & Toolchain Flags</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    fw_flow_desc = (
        "VeeR EL2 executes bare-metal C programs with no operating system or dynamic loader. The build pipeline relies on:<br/>"
        "• <b>Bootstrap Assembler (crt0.S):</b> Executes at reset vector 0x0000_0000 (_start). Configures Global Pointer (gp), "
        "initializes Stack Pointer (sp = __stack_top in DMEM), zeroes the uninitialized .bss segment, and branches to main().<br/>"
        "• <b>Linker Script (link.ld):</b> Maps .text into IMEM (0x0000_0000, 32 KB) and routes .data, .bss, and stack into DMEM (0x1000_0000, 32 KB).<br/>"
        "• <b>Binary Utility (objcopy):</b> Converts compiled ELF images into Verilog memory byte hex format (.hex) read via $readmemh.<br/>"
        "• <b>Stand-in Generator (gen_default_hex.py):</b> A standalone Python script capable of synthesizing valid RV32I machine-code hex images without requiring a full toolchain installation."
    )
    story.append(Paragraph(fw_flow_desc, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    l45_code = (
        "# sw/Makefile -- Bare-metal compilation pipeline\n"
        "XCHAIN  := /opt/riscv/bin/riscv64-unknown-elf\n"
        "CC      := $(XCHAIN)-gcc\n"
        "OBJCOPY := $(XCHAIN)-objcopy\n"
        "OBJDUMP := $(XCHAIN)-objdump\n\n"
        "CFLAGS  := -march=rv32imc_zicsr -mabi=ilp32 -O2 -g \\\n"
        "           -ffreestanding -nostdlib -nostartfiles \\\n"
        "           -fno-common -fomit-frame-pointer -Wall\n\n"
        "# 1. Compile C + crt0.S to ELF\n"
        "main.elf: crt0.S main.c uart.c timer.c gpio.c i2c.c fir.c pwm.c link.ld\n"
        "\t$(CC) $(CFLAGS) -T link.ld -o $@ crt0.S main.c uart.c timer.c gpio.c i2c.c fir.c pwm.c\n\n"
        "# 2. Extract Verilog-compatible hex format for simulation\n"
        "main.hex: main.elf\n"
        "\t$(OBJCOPY) -O verilog --verilog-data-width=1 $< $@\n\n"
        "# 3. Generate human-readable disassembly for pipeline inspection\n"
        "main.dump: main.elf\n"
        "\t$(OBJDUMP) -d -S -M no-aliases $< > $@"
    )
    story.append(make_code_box("4.5: Bare-Metal Firmware Build Pipeline (sw/Makefile)", l45_code, styles))
    story.append(PageBreak())

    # =============================================================
    # CHAPTER 5: ADDRESS MAP
    # =============================================================
    story.append(Paragraph("<b>Chapter 5</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>ADDRESS MAP</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 5.1 System-Wide Memory Map Overview
    story.append(Paragraph("<b>5.1  System-Wide Memory Map Overview</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    mm_text = (
        "The SoC memory space is organized into tightly coupled CPU memories (IMEM and DMEM) and memory-mapped "
        "peripheral registers allocated across distinct 4 KB apertures in the 0x8000_0000 range. The central address decoder "
        "(axi4lite_decoder) evaluates address bits ADDR[31:12] to route transactions to target slaves. Any bus access attempting "
        "unaligned word transfers (ADDR[1:0] != 2'b00) or partial byte writes (WSTRB != 4'b1111) returns SLVERR (2'b10). "
        "Accesses targeting unmapped address holes route to axi4lite_err_slave and return DECERR (2'b11)."
    )
    story.append(Paragraph(mm_text, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 5.2 Master Memory Aperture Summary Table
    story.append(Paragraph("<b>5.2  Master Memory Aperture Summary Table</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))

    mem_data = [
        [Paragraph("<b>Region / Peripheral</b>", styles['TableHdr']), Paragraph("<b>Base Address</b>", styles['TableHdr']), Paragraph("<b>End Address</b>", styles['TableHdr']), Paragraph("<b>Size</b>", styles['TableHdr']), Paragraph("<b>Bus Interface</b>", styles['TableHdr']), Paragraph("<b>Description</b>", styles['TableHdr'])],
        [Paragraph("IMEM (Dual-Port)", styles['TableBodyBold']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("0x0000_7FFF", styles['TableBody']), Paragraph("32 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 0", styles['TableBody']), Paragraph("Instruction Memory (Port A: IFU direct fetch, Port B: LSU)", styles['TableBody'])],
        [Paragraph("DMEM (Single-Port)", styles['TableBodyBold']), Paragraph("0x1000_0000", styles['TableBody']), Paragraph("0x1000_7FFF", styles['TableBody']), Paragraph("32 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 1", styles['TableBody']), Paragraph("Data Memory (Stack, heap, sample buffers, globals)", styles['TableBody'])],
        [Paragraph("UART Controller", styles['TableBodyBold']), Paragraph("0x8000_0000", styles['TableBody']), Paragraph("0x8000_0FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 2", styles['TableBody']), Paragraph("8-N-1 UART with 16-byte TX/RX FIFOs and baud divisor", styles['TableBody'])],
        [Paragraph("Machine Timer", styles['TableBodyBold']), Paragraph("0x8000_1000", styles['TableBody']), Paragraph("0x8000_1FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 3", styles['TableBody']), Paragraph("64-bit mtime/mtimecmp timer and compare interrupt", styles['TableBody'])],
        [Paragraph("GPIO Controller", styles['TableBodyBold']), Paragraph("0x8000_2000", styles['TableBody']), Paragraph("0x8000_2FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 4", styles['TableBody']), Paragraph("16-bit bidir IO pins with edge/level interrupt generation", styles['TableBody'])],
        [Paragraph("I2C Controller", styles['TableBodyBold']), Paragraph("0x8000_3000", styles['TableBody']), Paragraph("0x8000_3FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 5", styles['TableBody']), Paragraph("Master I2C interface with open-drain buffers", styles['TableBody'])],
        [Paragraph("FIR Filter", styles['TableBodyBold']), Paragraph("0x8000_4000", styles['TableBody']), Paragraph("0x8000_4FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 6", styles['TableBody']), Paragraph("16-tap direct-form MAC accelerator (Q1.15 fixed point)", styles['TableBody'])],
        [Paragraph("PWM Generator", styles['TableBodyBold']), Paragraph("0x8000_5000", styles['TableBody']), Paragraph("0x8000_5FFF", styles['TableBody']), Paragraph("4 KB", styles['TableBody']), Paragraph("AXI4-Lite Slave 7", styles['TableBody']), Paragraph("Double-buffered PWM generator with polarity inversion", styles['TableBody'])],
        [Paragraph("Unmapped Space", styles['TableBodyBold']), Paragraph("All Others", styles['TableBody']), Paragraph("All Others", styles['TableBody']), Paragraph("-", styles['TableBody']), Paragraph("AXI4-Lite Slave 8", styles['TableBody']), Paragraph("Decode error slave returning DECERR (2'b11)", styles['TableBody'])],
    ]
    t_mem = Table(mem_data, colWidths=[95, 70, 70, 40, 85, 120])
    t_mem.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(Paragraph("<b>Table 5.1:</b> Master System Memory Map and Peripheral Address Apertures", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_mem)
    story.append(Spacer(1, 10))

    # 5.3 Detailed Peripheral Register Maps
    story.append(Paragraph("<b>5.3  Detailed Peripheral Register Maps</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))

    # Table 5.2 UART
    uart_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("UART_DATA", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[7:0] Data byte. Write: TX FIFO data; Read: Pop RX FIFO byte.", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("UART_STATUS", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("0x0000_0006", styles['TableBody']), Paragraph("[0] TX_FULL; [1] TX_EMPTY; [2] RX_EMPTY; [3] RX_FULL; [4] OVERRUN; [5] FRAME_ERR.", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("UART_BAUDDIV", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0036", styles['TableBody']), Paragraph("[15:0] Baud divisor = Fsys / (16 * Baud) - 1. Set to 54 for 115200 baud @ 100MHz (434 @ 50MHz).", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("UART_CTRL", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0003", styles['TableBody']), Paragraph("[0] TX_EN (Transmitter enable); [1] RX_EN (Receiver enable).", styles['TableBody'])],
    ]
    t_uart_r = Table(uart_regs, colWidths=[45, 80, 45, 75, 235])
    t_uart_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.2:</b> UART Controller Register Map (Base Address 0x8000_0000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_uart_r)
    story.append(Spacer(1, 8))

    # Table 5.3 Timer
    tmr_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("MTIME_LO", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[31:0] Lower 32 bits of 64-bit real-time counter (mtime[31:0]).", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("MTIME_HI", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[31:0] Upper 32 bits of 64-bit real-time counter (mtime[63:32]).", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("MTIMECMP_LO", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0xFFFF_FFFF", styles['TableBody']), Paragraph("[31:0] Lower 32 bits of 64-bit compare register (mtimecmp[31:0]).", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("MTIMECMP_HI", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0xFFFF_FFFF", styles['TableBody']), Paragraph("[31:0] Upper 32 bits of 64-bit compare register (mtimecmp[63:32]).", styles['TableBody'])],
        [Paragraph("0x10", styles['TableBodyBold']), Paragraph("TIMER_CTRL", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[0] EN (Counter increment enable); [1] IRQ_EN (Compare match interrupt enable).", styles['TableBody'])],
        [Paragraph("0x14", styles['TableBodyBold']), Paragraph("TIMER_PRESCALE", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Prescaler division ratio (N+1).", styles['TableBody'])],
    ]
    t_tmr_r = Table(tmr_regs, colWidths=[45, 80, 45, 75, 235])
    t_tmr_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.3:</b> RISC-V Machine Timer Register Map (Base Address 0x8000_1000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_tmr_r)
    story.append(Spacer(1, 8))

    # Table 5.4 GPIO
    gpio_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("GPIO_DATA_OUT", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Output drive value for pins configured as outputs.", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("GPIO_DATA_IN", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("Pin State", styles['TableBody']), Paragraph("[15:0] Synchronized input pin values (via 2-stage FF synchronizer).", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("GPIO_DIR", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Pin direction: 1 = output, 0 = input (default input).", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("GPIO_IRQ_MASK", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Interrupt enable mask per pin (1 = enabled).", styles['TableBody'])],
        [Paragraph("0x10", styles['TableBodyBold']), Paragraph("GPIO_IRQ_EDGE", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Trigger type: 1 = rising edge, 0 = active-high level.", styles['TableBody'])],
        [Paragraph("0x14", styles['TableBodyBold']), Paragraph("GPIO_IRQ_STAT", styles['TableBody']), Paragraph("W1C", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Interrupt pending status; write 1 to clear pending flag.", styles['TableBody'])],
    ]
    t_gpio_r = Table(gpio_regs, colWidths=[45, 80, 45, 75, 235])
    t_gpio_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.4:</b> GPIO Subsystem Register Map (Base Address 0x8000_2000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_gpio_r)
    story.append(Spacer(1, 8))

    # Table 5.5 I2C
    i2c_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("I2C_PRER_LO", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_00FF", styles['TableBody']), Paragraph("[7:0] Prescaler lower 8 bits. Clock div = Fsys / (5 * Fscl) - 1.", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("I2C_PRER_HI", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_00FF", styles['TableBody']), Paragraph("[7:0] Prescaler upper 8 bits.", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("I2C_CTRL", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[7] EN (Core enable); [6] IRQ_EN (Interrupt enable).", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("I2C_DATA", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[7:0] Transmit data register (TXR) / Receive data register (RXR).", styles['TableBody'])],
        [Paragraph("0x10", styles['TableBodyBold']), Paragraph("I2C_CMD_STAT", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("Write CMD: [7] STA, [6] STO, [5] RD, [4] WR, [3] ACK, [0] IACK.<br/>Read STAT: [7] RXACK, [6] BUSY, [1] TIP, [0] IF.", styles['TableBody'])],
    ]
    t_i2c_r = Table(i2c_regs, colWidths=[45, 80, 45, 75, 235])
    t_i2c_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.5:</b> I2C Controller Register Map (Base Address 0x8000_3000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_i2c_r)
    story.append(Spacer(1, 8))

    # Table 5.6 FIR
    fir_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("FIR_CTRL", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[0] EN (Enable); [1] FLUSH (Clear delay line); [2] IRQ_EN (Done IRQ).", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("FIR_STATUS", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("0x0000_0001", styles['TableBody']), Paragraph("[0] IDLE (Ready for sample); [1] DONE (Sample ready); [2] BUSY; [3] SAT (Sticky saturation).", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("FIR_DATA_IN", styles['TableBody']), Paragraph("WO", styles['TableBody']), Paragraph("-", styles['TableBody']), Paragraph("[15:0] Input sample x[n] (Q1.15 signed). Writing triggers computation.", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("FIR_DATA_OUT", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Filtered output y[n] (Q1.15 signed, saturated to [-32768, 32767]).", styles['TableBody'])],
        [Paragraph("0x10", styles['TableBodyBold']), Paragraph("FIR_COEF_ADDR", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[3:0] Coefficient RAM address index (0 to 15).", styles['TableBody'])],
        [Paragraph("0x14", styles['TableBodyBold']), Paragraph("FIR_COEF_DATA", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Coefficient weight h[k] (Q1.15 signed).", styles['TableBody'])],
        [Paragraph("0x18", styles['TableBodyBold']), Paragraph("FIR_SHIFT", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_000F", styles['TableBody']), Paragraph("[4:0] Arithmetic right shift amount (default 15 for Q1.15 scaling).", styles['TableBody'])],
        [Paragraph("0x1C", styles['TableBodyBold']), Paragraph("FIR_TAPS", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("0x0000_0010", styles['TableBody']), Paragraph("[7:0] Hardware tap count implemented (16).", styles['TableBody'])],
    ]
    t_fir_r = Table(fir_regs, colWidths=[45, 80, 45, 75, 235])
    t_fir_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.6:</b> FIR Filter Accelerator Register Map (Base Address 0x8000_4000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_fir_r)
    story.append(Spacer(1, 8))

    # Table 5.7 PWM
    pwm_regs = [
        [Paragraph("<b>Offset</b>", styles['TableHdr']), Paragraph("<b>Register</b>", styles['TableHdr']), Paragraph("<b>Access</b>", styles['TableHdr']), Paragraph("<b>Reset Value</b>", styles['TableHdr']), Paragraph("<b>Bit Fields & Description</b>", styles['TableHdr'])],
        [Paragraph("0x00", styles['TableBodyBold']), Paragraph("PWM_CTRL", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[0] EN (Counter enable); [1] POL (0=active-high, 1=active-low); [2] IRQ_EN; [3] FORCE reload.", styles['TableBody'])],
        [Paragraph("0x04", styles['TableBodyBold']), Paragraph("PWM_PERIOD", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Period reload threshold (shadowed, reloads on counter rollover).", styles['TableBody'])],
        [Paragraph("0x08", styles['TableBodyBold']), Paragraph("PWM_DUTY", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Duty cycle match threshold (shadowed, reloads on rollover).", styles['TableBody'])],
        [Paragraph("0x0C", styles['TableBodyBold']), Paragraph("PWM_PRESCALE", styles['TableBody']), Paragraph("RW", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Clock prescaler divisor ratio (N+1).", styles['TableBody'])],
        [Paragraph("0x10", styles['TableBodyBold']), Paragraph("PWM_COUNT", styles['TableBody']), Paragraph("RO", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[15:0] Current free-running counter value.", styles['TableBody'])],
        [Paragraph("0x14", styles['TableBodyBold']), Paragraph("PWM_STATUS", styles['TableBody']), Paragraph("RO/W1C", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("[0] ROLLOVER_IRQ pending flag; write 1 to clear.", styles['TableBody'])],
    ]
    t_pwm_r = Table(pwm_regs, colWidths=[45, 80, 45, 75, 235])
    t_pwm_r.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 5.7:</b> PWM Generator Register Map (Base Address 0x8000_5000)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_pwm_r)
    story.append(PageBreak())

    # =============================================================
    # CHAPTER 6: TESTPLAN WITH EXTERNAL / INTERNAL TEST COLUMN
    # =============================================================
    story.append(Paragraph("<b>Chapter 6</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>TESTPLAN WITH EXTERNAL / INTERNAL TEST COLUMN</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 6.1 Verification Methodology & Testplan Architecture
    story.append(Paragraph("<b>6.1  Verification Methodology & Testplan Architecture</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    vp_text = (
        "Functional verification of the VeeR EL2 SoC employs a dual-faceted co-verification strategy combining "
        "internal software execution on the CPU core with external hardware protocol checks in SystemVerilog/UVM:<br/>"
        "• <b>Internal Test Verification (C Firmware):</b> Bare-metal C programs executing from IMEM exercise peripheral "
        "registers, configure sampling cadence, poll status flags, service PIC interrupts, and emit telemetry strings via UART.<br/>"
        "• <b>External Test Verification (SV / UVM):</b> VIP agents drive asynchronous external pad events (serial UART RX bits, "
        "I2C sensor slave responses, GPIO transitions), snoop AXI bus transactions, verify protocol handshake rules, monitor interrupt lines, "
        "and assert functional correctness against golden models."
    )
    story.append(Paragraph(vp_text, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 6.2 Complete SoC Verification Matrix (24 Test Cases)
    story.append(Paragraph("<b>6.2  Complete SoC Verification Matrix (24 Test Cases)</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))

    test_matrix = [
        [Paragraph("<b>SNo</b>", styles['TableHdr']), Paragraph("<b>Test ID</b>", styles['TableHdr']), Paragraph("<b>Description & Checkpoint</b>", styles['TableHdr']), Paragraph("<b>Internal Test (C Verification Part)</b>", styles['TableHdr']), Paragraph("<b>External Test (SV/UVM Verification Part)</b>", styles['TableHdr'])],
        [Paragraph("1", styles['TableBodyBold']), Paragraph("TC_BOOT_01", styles['TableBodyBold']), Paragraph("Reset & Vector Fetch Check: CPU boots from 0x0000_0000 into IMEM.", styles['TableBody']), Paragraph("Execute crt0.S bootstrap, set gp/sp, zero .bss, branch to main().", styles['TableBody']), Paragraph("Deassert rst_n after 20 cycles; check trace_rv_i_address_ip == 32'h0.", styles['TableBody'])],
        [Paragraph("2", styles['TableBodyBold']), Paragraph("TC_BOOT_02", styles['TableBodyBold']), Paragraph("DMEM Stack & Memory Integrity: Read/write stack frames in DMEM.", styles['TableBody']), Paragraph("Push/pop nested function frames in DMEM (0x1000_0000). Check 0 ECC errors.", styles['TableBody']), Paragraph("Snoop LSU bus; assert dccm_ecc_single_error == 0 and trace exception == 0.", styles['TableBody'])],
        [Paragraph("3", styles['TableBodyBold']), Paragraph("TC_UART_01", styles['TableBodyBold']), Paragraph("UART Baud & Control Setup: Verify BAUDDIV, CTRL, and DATA readback.", styles['TableBody']), Paragraph("Write 0x03 to CTRL (TX/RX enable), 54 to BAUDDIV; assert register persistence.", styles['TableBody']), Paragraph("BFM snoops AXI slave 2 (0x8000_0000); verifies awready/wready and bresp=OKAY.", styles['TableBody'])],
        [Paragraph("4", styles['TableBodyBold']), Paragraph("TC_UART_02", styles['TableBodyBold']), Paragraph("UART Character Serialization: Transmit character 'K' (0x4B) across uart_tx.", styles['TableBody']), Paragraph("Poll STATUS until TX_EMPTY, write 0x4B to DATA; wait for transmit completion.", styles['TableBody']), Paragraph("uart_agent monitor samples falling edge, 8 data bits mid-period, stop bit (8'h4B).", styles['TableBody'])],
        [Paragraph("5", styles['TableBodyBold']), Paragraph("TC_UART_03", styles['TableBodyBold']), Paragraph("UART RX Reception & Loopback: Inject byte 0xA5 into uart_rx pin.", styles['TableBody']), Paragraph("Poll STATUS[2] (RX_EMPTY==0), read DATA, assert received byte == 0xA5.", styles['TableBody']), Paragraph("VIP driver serializes 0xA5 onto uart_rx; asserts irq_uart high upon byte arrival.", styles['TableBody'])],
        [Paragraph("6", styles['TableBodyBold']), Paragraph("TC_UART_04", styles['TableBodyBold']), Paragraph("UART FIFO Overrun Check: Stream 18 bytes into 16-byte FIFO.", styles['TableBody']), Paragraph("Allow FIFO to overflow without reading; verify OVERRUN flag (bit 4) sets in STATUS.", styles['TableBody']), Paragraph("Scoreboard checks irq_uart remains asserted and AXI interface does not lock.", styles['TableBody'])],
        [Paragraph("7", styles['TableBodyBold']), Paragraph("TC_TMR_01", styles['TableBodyBold']), Paragraph("Timer Monotonic Increment: Program prescaler, enable counter increment.", styles['TableBody']), Paragraph("Write PRESCALE=49, CTRL=1. Sample t0=MTIME_LO, delay 50 NOPs, assert t1 > t0.", styles['TableBody']), Paragraph("Snoop AXI slave 3; verify mtime counter increments monotonically every 50 clocks.", styles['TableBody'])],
        [Paragraph("8", styles['TableBodyBold']), Paragraph("TC_TMR_02", styles['TableBodyBold']), Paragraph("Timer Compare Match Interrupt: Trigger compare match between mtime and cmp.", styles['TableBody']), Paragraph("Set MTIMECMP_LO = t0 + 100, CTRL[1]=1. Wait for interrupt flag, clear IRQ.", styles['TableBody']), Paragraph("Monitor irq_timer pin; assert transition 0 -> 1 exactly on counter equality.", styles['TableBody'])],
        [Paragraph("9", styles['TableBodyBold']), Paragraph("TC_GPIO_01", styles['TableBodyBold']), Paragraph("GPIO Pin Direction & Output Drive: Configure lower 8 pins as outputs.", styles['TableBody']), Paragraph("Write DIR=0x00FF, DATA_OUT=0x00AA. Read back register reflection.", styles['TableBody']), Paragraph("Sample external gpio[7:0] pins; check gpio[7:0] == 8'hAA and oe[7:0] == 8'hFF.", styles['TableBody'])],
        [Paragraph("10", styles['TableBodyBold']), Paragraph("TC_GPIO_02", styles['TableBodyBold']), Paragraph("GPIO External Input Sampling: Drive external stimulus into gpio pins.", styles['TableBody']), Paragraph("Read DATA_IN (0x8000_2004) and compare against expected injected stimulus pattern.", styles['TableBody']), Paragraph("Drive gpio[15:8] = 8'h55; verify signal propagates through 2-FF synchronizer.", styles['TableBody'])],
        [Paragraph("11", styles['TableBodyBold']), Paragraph("TC_GPIO_03", styles['TableBodyBold']), Paragraph("GPIO Edge-Triggered Interrupt: Configure rising-edge trigger on pin 0.", styles['TableBody']), Paragraph("Set IRQ_MASK=0x1, IRQ_EDGE=0x1. Poll IRQ_STAT for bit 0. Clear via W1C.", styles['TableBody']), Paragraph("Pulse gpio[0] 0 -> 1; verify irq_gpio asserts high and clears upon W1C write.", styles['TableBody'])],
        [Paragraph("12", styles['TableBodyBold']), Paragraph("TC_I2C_01", styles['TableBodyBold']), Paragraph("I2C Bus Initialization & Prescaler: Setup 100 kHz SCL clock divider.", styles['TableBody']), Paragraph("Program PRER_LO=124, CTRL=0x80 (enable core). Check status idle.", styles['TableBody']), Paragraph("Snoop AXI slave 5; verify SCL clock frequency matches 100 kHz (50 MHz / 500).", styles['TableBody'])],
        [Paragraph("13", styles['TableBodyBold']), Paragraph("TC_I2C_02", styles['TableBodyBold']), Paragraph("I2C Master Write & START/STOP: Send device address 0x48 (Write mode).", styles['TableBody']), Paragraph("Write 0x90 to DATA, write 0x90 to CMD (STA|WR). Poll TIP until 0, check RXACK=0.", styles['TableBody']), Paragraph("i2c_sensor_model detects START condition, samples address 0x48, drives SDA low (ACK).", styles['TableBody'])],
        [Paragraph("14", styles['TableBodyBold']), Paragraph("TC_I2C_03", styles['TableBodyBold']), Paragraph("I2C 16-Bit Sensor Read: Read MSB and LSB from temperature sensor.", styles['TableBody']), Paragraph("Execute 2-byte read sequence with ACK and NACK on last byte; assemble raw sample.", styles['TableBody']), Paragraph("Sensor model returns 16-bit signed sample (e.g. 0x05A0 = +1440); checks bus framing.", styles['TableBody'])],
        [Paragraph("15", styles['TableBodyBold']), Paragraph("TC_FIR_01", styles['TableBodyBold']), Paragraph("FIR Coefficient Programming: Write 16 Q1.15 weights into coefficient RAM.", styles['TableBody']), Paragraph("Iterate i=0..15: set COEF_ADDR=i, COEF_DATA=fir_coeffs[i]. Read back & verify.", styles['TableBody']), Paragraph("Snoop AXI slave 6; verify coefficient RAM writes and check TAPS register reads 16.", styles['TableBody'])],
        [Paragraph("16", styles['TableBodyBold']), Paragraph("TC_FIR_02", styles['TableBodyBold']), Paragraph("FIR Impulse Response Check: Inject single impulse sample x[0]=0x7FFF.", styles['TableBody']), Paragraph("Write DATA_IN=0x7FFF; poll STATUS for DONE. Verify output y[0] matches h[0].", styles['TableBody']), Paragraph("Scoreboard compares hardware output against C/DPI reference model; assert match.", styles['TableBody'])],
        [Paragraph("17", styles['TableBodyBold']), Paragraph("TC_FIR_03", styles['TableBodyBold']), Paragraph("FIR Saturation Detection: Force overflow to test saturation clipping.", styles['TableBody']), Paragraph("Write successive large samples (+32767). Poll STATUS; assert SAT flag (bit 3) sets.", styles['TableBody']), Paragraph("Scoreboard confirms output clamps to 32767 and accumulator does not wrap around.", styles['TableBody'])],
        [Paragraph("18", styles['TableBodyBold']), Paragraph("TC_PWM_01", styles['TableBodyBold']), Paragraph("PWM Period & Duty Setup: Configure 1 kHz PWM with 50% duty cycle.", styles['TableBody']), Paragraph("Write PERIOD=999, DUTY=500, PRESCALE=49, CTRL=1. Verify counter counts.", styles['TableBody']), Paragraph("pwm_monitor measures output pin duty cycle; verifies ratio is 50.0% +/- 0.1%.", styles['TableBody'])],
        [Paragraph("19", styles['TableBodyBold']), Paragraph("TC_PWM_02", styles['TableBodyBold']), Paragraph("PWM Shadow Reload Glitch Check: Update duty cycle dynamically while active.", styles['TableBody']), Paragraph("Write DUTY=750 during active count. Assert duty update reflects without glitch.", styles['TableBody']), Paragraph("pwm_monitor confirms active cycle finishes at 50% and next cycle smoothly uses 75%.", styles['TableBody'])],
        [Paragraph("20", styles['TableBodyBold']), Paragraph("TC_BRG_01", styles['TableBodyBold']), Paragraph("LSU Bridge 64-to-32 Bit Width Split: Execute 64-bit load/store across bridge.", styles['TableBody']), Paragraph("Execute 64-bit store from VeeR EL2. Verify lower and upper 32-bit words routed cleanly.", styles['TableBody']), Paragraph("Monitor interconnect master bus; verify awsize clamped to 3'b010 and ADDR[2] steering.", styles['TableBody'])],
        [Paragraph("21", styles['TableBodyBold']), Paragraph("TC_BUS_01", styles['TableBodyBold']), Paragraph("Unmapped Address Access (DECERR): Access unmapped hole (0x8000_9000).", styles['TableBody']), Paragraph("Perform 32-bit load to 0x8000_9000; catch precise bus fault in mtvec trap handler.", styles['TableBody']), Paragraph("axi4lite_err_slave asserts bresp=2'b11 (DECERR) without hanging AXI handshake.", styles['TableBody'])],
        [Paragraph("22", styles['TableBodyBold']), Paragraph("TC_BUS_02", styles['TableBodyBold']), Paragraph("Partial Byte Strobe Rejection (SLVERR): Perform byte write to register.", styles['TableBody']), Paragraph("Execute sb x1, 0(x2) targeting peripheral register. Catch SLVERR in CPU trap handler.", styles['TableBody']), Paragraph("axi4lite_regif detects WSTRB != 4'b1111; asserts bresp=2'b10 (SLVERR) and drops write.", styles['TableBody'])],
        [Paragraph("23", styles['TableBodyBold']), Paragraph("TC_LOOP_01", styles['TableBodyBold']), Paragraph("Closed-Loop Pipeline (I2C -> FIR -> PWM): Ingest, filter, and actuate.", styles['TableBody']), Paragraph("Execute main() loop: I2C read sensor -> FIR filter -> map duty -> PWM set duty.", styles['TableBody']), Paragraph("Scoreboard tracks sample progression from I2C bus to PWM duty cycle change.", styles['TableBody'])],
        [Paragraph("24", styles['TableBodyBold']), Paragraph("TC_FULL_01", styles['TableBodyBold']), Paragraph("Full Regression Sign-Off: Boot, configure, run 5 iterations, print PASS.", styles['TableBody']), Paragraph("Run full main.c; transmit '[SoC] PASS! VeeR EL2 Online' via UART; return 0.", styles['TableBody']), Paragraph("Testbench UART detector detects 'PASS'; prints '=== [TEST] tb_soc_top: PASS ==='.", styles['TableBody'])],
    ]
    t_mat = Table(test_matrix, colWidths=[24, 60, 115, 135, 146])
    t_mat.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 6.1:</b> Comprehensive 24-Test SoC Verification Matrix (Internal C vs. External SV/UVM)", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_mat)
    story.append(PageBreak())

    return story
