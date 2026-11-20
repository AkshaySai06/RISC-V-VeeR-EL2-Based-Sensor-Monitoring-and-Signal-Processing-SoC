# -*- coding: utf-8 -*-
"""
sections_ch1_to_ch3.py
Chapters 1, 2, and 3:
- Chapter 1: Project Proposal (1.1 - 1.6, Table 1.1)
- Chapter 2: Architecture Specification (2.1 - 2.6, Tables 2.1, 2.2, 2.3, Fig 2.1)
- Chapter 3: GitHub Account Steps (3.1 - 3.5, Listings 3.1 - 3.5)
"""

import os
from reportlab.platypus import Paragraph, Spacer, Table, TableStyle, PageBreak, Image, HRFlowable, KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from report_sections import GITHUB_REPO_URL, COMMIT_HASH

def make_callout_box(title, text, styles, width=480):
    content = [
        Paragraph(f"<b>{title}</b>", styles['CalloutTitle']),
        Spacer(1, 4),
        Paragraph(text, styles['CalloutBody'])
    ]
    t = Table([[content]], colWidths=[width])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#f0f4f9")),
        ('BOX', (0,0), (-1,-1), 1.2, colors.HexColor("#1a73e8")),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
    ]))
    return t

def make_code_box(title, code_str, styles, width=480):
    lines = code_str.strip().split("\n")
    formatted_lines = []
    for idx, l in enumerate(lines):
        line_num = f"{idx+1:2d} "
        safe_l = l.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace(" ", "&nbsp;")
        formatted_lines.append(f"<font color='#888888'>{line_num}</font>{safe_l}")
    
    code_p = Paragraph("<br/>".join(formatted_lines), styles['CodeBody'])
    title_p = Paragraph(f"<b>Listing: {title}</b>", styles['CodeTitle'])
    
    t = Table([[title_p], [code_p]], colWidths=[width])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#e9ecef")),
        ('BACKGROUND', (0,1), (-1,1), colors.HexColor("#f8f9fa")),
        ('BOX', (0,0), (-1,-1), 0.8, colors.HexColor("#ced4da")),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    return t

def get_ch1_to_ch3_flowables(styles):
    story = []

    # =============================================================
    # CHAPTER 1: PROJECT PROPOSAL
    # =============================================================
    story.append(Paragraph("<b>Chapter 1</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>PROJECT PROPOSAL</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 1.1 Project Title and Classification
    story.append(Paragraph("<b>1.1  Project Title and Classification</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    p_info = (
        "• <b>Project Title:</b> RISC-V VeeR EL2 Based Sensor Monitoring and Signal Processing SoC<br/>"
        "• <b>Target Domain:</b> Cyber-Physical Systems / Embedded Digital Signal Processing / Edge Sensing<br/>"
        "• <b>Project Category:</b> Advanced VLSI & SoC Design, Embedded Systems Architecture, UVM Verification<br/>"
        "• <b>Author / Candidate:</b> Veeramalla Akshay (Roll No: 1602-23-735-130), Department of Electronics and "
        "Communication Engineering, Vasavi College of Engineering (Autonomous), Hyderabad."
    )
    story.append(Paragraph(p_info, styles['BodyJustify']))
    story.append(Spacer(1, 12))

    # 1.2 Industrial Context & Background
    story.append(Paragraph("<b>1.2  Industrial Context & Background: Cyber-Physical Systems</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    ctx_text1 = (
        "Modern embedded sensing and cyber-physical systems (CPS) — spanning industrial automation, autonomous "
        "robotics, avionics telemetry, smart power grids, and biomedical health monitors — adhere to a recurring, "
        "deterministic operational paradigm: <b>Acquire → Condition → Actuate</b>. In these applications, continuous "
        "streams of analog physical phenomena (such as vibration, temperature, pressure, motor rotational speed, and "
        "displacement) are periodically sampled over standard serial peripheral interfaces."
    )
    ctx_text2 = (
        "However, real-world sensor streams are inherently corrupted by high-frequency environmental noise, thermal "
        "drift, electrical EMI coupling, and quantization artifacts. To generate reliable closed-loop control signals, "
        "the raw sample stream must undergo rigorous digital signal conditioning — typically through linear-phase "
        "Finite Impulse Response (FIR) filtering — before being transformed into high-precision duty-cycle-modulated "
        "actuator drive waveforms (such as Pulse Width Modulation for motors, solenoids, or heaters). Simultaneously, "
        "processed status telemetry and forensic diagnostics must be continuously serialized and transmitted to a host "
        "monitoring station without interrupting the core real-time control cadence."
    )
    story.append(Paragraph(ctx_text1, styles['BodyJustify']))
    story.append(Spacer(1, 8))
    story.append(Paragraph(ctx_text2, styles['BodyJustify']))
    story.append(Spacer(1, 12))

    # 1.3 Problem Statement
    story.append(Paragraph("<b>1.3  Problem Statement</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    prob_intro = (
        "Conventional embedded sensor-monitoring architectures rely heavily on general-purpose microcontrollers "
        "executing software polling routines, interrupt service routines (ISRs), and software-implemented digital filtering loops. "
        "This software-centric architecture introduces catastrophic vulnerabilities under high-bandwidth and time-critical conditions:"
    )
    story.append(Paragraph(prob_intro, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    prob_points = (
        "<b>1. Computational Bottlenecks in Software Filtering:</b> Implementing digital signal processing algorithms "
        "(such as a 16-tap FIR filter) purely in software consumes dozens of clock cycles per sample for multiply-accumulate "
        "(MAC) loops, array boundary checks, circular buffer pointer updates, and saturation clipping. This compute load "
        "absorbs over 75% of available CPU clock cycles, preventing the core from executing complex application decisions.<br/><br/>"
        "<b>2. Severe Interrupt Overhead and Execution Jitter:</b> Servicing high-frequency sensor interrupts triggers constant "
        "pipeline flushes, register context saving/restoring, and branch mispredictions. The resulting non-deterministic interrupt "
        "latency introduces timing jitter into both sampling cadence and actuator response, destabilizing critical control loops.<br/><br/>"
        "<b>3. Bus Protocol and Width Mismatches:</b> High-performance RISC-V processor cores, such as the CHIPS Alliance "
        "VeeR EL2, utilize high-throughput 64-bit AMBA AXI4 interfaces with multi-beat burst capabilities. Conversely, modular "
        "peripheral IPs are architected around lightweight 32-bit single-beat AXI4-Lite protocols. Bridging these distinct bus "
        "domains without causing transaction deadlocks or address misalignment faults presents a critical engineering hurdle.<br/><br/>"
        "<b>4. Actuator Glitches from Asynchronous Updates:</b> Dynamically modifying PWM duty cycle registers while the counter "
        "is actively running causes duty cycle truncations, missing pulses, and electrical shoot-through in power H-bridges unless "
        "hardware double-buffering is implemented."
    )
    story.append(Paragraph(prob_points, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    callout_prob = (
        "Conventional software-driven sensor architectures suffer from severe CPU saturation, arithmetic latency, "
        "and execution jitter during high-rate signal filtering. By offloading digital filtering, bus bridging, "
        "and actuator pulse generation entirely into dedicated hardware IP blocks, the central RISC-V core remains "
        "free to orchestrate high-level telemetry and control policies with zero pipeline stalling."
    )
    story.append(make_callout_box("CRITICAL PROBLEM SUMMARY", callout_prob, styles))
    story.append(Spacer(1, 14))

    # 1.4 Proposed Solution & Architectural Innovation
    story.append(Paragraph("<b>1.4  Proposed Solution & Architectural Innovation</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    sol_intro = (
        "To resolve these bottlenecks and provide deterministic, cycle-accurate performance guarantees, this project "
        "architects, integrates, and verifies a complete <b>RISC-V VeeR EL2 Based Sensor Monitoring and Signal Processing SoC</b>. "
        "The architecture introduces dedicated hardware acceleration across every stage of the telemetry pipeline:"
    )
    story.append(Paragraph(sol_intro, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    sol_points = (
        "<b>1. Hardware I2C Master Subsystem:</b> A dedicated I2C controller with clock prescaler, automatic START/STOP/ACK "
        "generation, and open-drain bidirectional IO pads autonomously acquires 16-bit raw sensor data from external I2C devices.<br/>"
        "<b>2. Dedicated 16-Tap Q1.15 FIR Accelerator:</b> A custom synthesizable DSP accelerator executes 16-tap digital "
        "filtering in dedicated hardware using fixed-point Q1.15 signed arithmetic with automatic saturation clipping [-32768, 32767]. "
        "The core simply writes an input sample and reads the smoothed output after deterministic MAC cycles.<br/>"
        "<b>3. Glitch-Free Double-Buffered PWM Generator:</b> Implements shadowed period and duty cycle registers that reload "
        "strictly on period counter rollover, guaranteeing smooth, glitch-free analog actuation.<br/>"
        "<b>4. Robust Protocol Bridging (axi4_to_axi4lite):</b> A custom synthesizable LSU bridge translates 64-bit AXI4 "
        "burst transactions from the VeeR EL2 core into compliant 32-bit single-beat AXI4-Lite transfers, featuring dynamic lane "
        "selection via address bit ADDR[2] and burst splitting.<br/>"
        "<b>5. Reusable AXI4-Lite Slave Register Interface (axi4lite_regif):</b> A single, verified register interface shim is "
        "shared across all peripheral IPs, enforcing strict 32-bit alignment and rejecting partial byte strobes with SLVERR.<br/>"
        "<b>6. Non-Blocking Dual-Port Instruction Memory:</b> A 32 KB Dual-Port IMEM allows the CPU IFU to fetch instructions "
        "over Port A with zero wait states while LSU can concurrently access data or firmware images over Port B."
    )
    story.append(Paragraph(sol_points, styles['BodyJustify']))
    story.append(Spacer(1, 12))

    # 1.5 Project Objectives & Deliverables
    story.append(Paragraph("<b>1.5  Project Objectives & Deliverables</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    deliv_text = (
        "• <b>Deliverable 1 – Synthesizable SoC RTL Codebase:</b> Complete Verilog/SystemVerilog RTL including top-level "
        "integration (soc_top.sv), 1-to-9 AXI4-Lite crossbar, 64-to-32 bit LSU bridge, IFU bridge, dual-port IMEM, single-port DMEM, "
        "and all peripheral IP wrappers (UART, Timer, GPIO, I2C, FIR Filter, PWM, and Error Slave).<br/>"
        "• <b>Deliverable 2 – VeeR EL2 Core Configuration:</b> Tailored core parameters (-set=build_axi4, icache_enable=0), "
        "auto-generated configuration headers (common_defines.vh, el2_pdef.vh, el2_param.vh), and PIC interrupt mapping.<br/>"
        "• <b>Deliverable 3 – Bare-Metal C Firmware Suite:</b> Complete modular firmware drivers (uart.c, i2c.c, fir.c, pwm.c, "
        "timer.c, gpio.c), closed-loop application (main.c), bootstrap assembly (crt0.S), and linker script (link.ld) compiled into "
        "simulation-ready hex images (main.hex).<br/>"
        "• <b>Deliverable 4 – Standalone Unit Testbenches:</b> 11 comprehensive unit testbenches verifying bus protocol bridges, "
        "crossbars, memory models, and each peripheral core with 100% pass rate in Synopsys VCS.<br/>"
        "• <b>Deliverable 5 – Modular UVM 1.2 Verification Suite:</b> Industrial-grade UVM 1.2 testbench architecture featuring "
        "six custom Verification IPs (FIR, GPIO, I2C, PWM, Timer, UART VIPs), virtual sequencer coordination, and coverage collectors.<br/>"
        "• <b>Deliverable 6 – Simulation Logs & Cycle-Accurate Waveform Proofs:</b> Complete simulation logs and cycle-by-cycle "
        "waveform analysis captured via Synopsys VCS and Verdi/nWave demonstrating flawless pipeline throughput."
    )
    story.append(Paragraph(deliv_text, styles['BodyJustify']))
    story.append(Spacer(1, 14))

    # 1.6 Project Milestones & Work Breakdown
    story.append(Paragraph("<b>1.6  Project Milestones & Work Breakdown</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))

    m_data = [
        [Paragraph("<b>Milestone</b>", styles['TableHdr']), Paragraph("<b>Phase Description</b>", styles['TableHdr']), Paragraph("<b>Target Output</b>", styles['TableHdr']), Paragraph("<b>Verification Status</b>", styles['TableHdr'])],
        [Paragraph("M1", styles['TableBodyBold']), Paragraph("Architectural Specification & Memory Map", styles['TableBody']), Paragraph("VeeR_EL2_SoC_Design_Spec_AXI4Lite.pdf, register_map.md", styles['TableBody']), Paragraph("Completed & Signed Off", styles['TableBodyPass'])],
        [Paragraph("M2", styles['TableBodyBold']), Paragraph("AXI4-Lite Bus Infrastructure & Protocol Bridges", styles['TableBody']), Paragraph("axi4_to_axi4lite.sv, axi4lite_interconnect.sv, axi4lite_regif.sv", styles['TableBody']), Paragraph("Verified (PASS in VCS)", styles['TableBodyPass'])],
        [Paragraph("M3", styles['TableBodyBold']), Paragraph("DSP & Peripheral IP Development (FIR, I2C, PWM, UART, etc.)", styles['TableBody']), Paragraph("fir_filter.sv, i2c_ctrl.sv, pwm_gen.sv, uart.sv, timer.sv, gpio.sv", styles['TableBody']), Paragraph("Verified in VCS (11/11 TBs)", styles['TableBodyPass'])],
        [Paragraph("M4", styles['TableBodyBold']), Paragraph("Top-Level SoC Integration & VeeR EL2 Bring-Up", styles['TableBody']), Paragraph("soc_top.sv, 2-FF reset synchronizer, PIC interrupt binding", styles['TableBody']), Paragraph("Verified in VCS (tb_soc_top)", styles['TableBodyPass'])],
        [Paragraph("M5", styles['TableBodyBold']), Paragraph("Bare-Metal Firmware & Closed-Loop Control Loop", styles['TableBody']), Paragraph("crt0.S, link.ld, main.c, drivers, main.hex", styles['TableBody']), Paragraph("Verified (UART PASS Banner)", styles['TableBodyPass'])],
        [Paragraph("M6", styles['TableBodyBold']), Paragraph("UVM 1.2 VIP Architecture & Multi-Agent Testbench", styles['TableBody']), Paragraph("6 VIPs (*_if.sv, pkgs), soc_env.sv, soc_virtual_sequencer.sv", styles['TableBody']), Paragraph("Clean Compile & Run (0 Errors)", styles['TableBodyPass'])],
        [Paragraph("M7", styles['TableBodyBold']), Paragraph("Verdi Waveform Analysis & Honours CBP Documentation", styles['TableBody']), Paragraph("FSDB/VPD traces, waveform plots, Technical Report", styles['TableBody']), Paragraph("Final Sign-Off", styles['TableBodyPass'])],
    ]
    t_m = Table(m_data, colWidths=[55, 150, 180, 95])
    t_m.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(Paragraph("<b>Table 1.1:</b> Project Milestones and Work Breakdown Schedule", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_m)
    story.append(PageBreak())

    # =============================================================
    # CHAPTER 2: ARCHITECTURE SPECIFICATION
    # =============================================================
    story.append(Paragraph("<b>Chapter 2</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>ARCHITECTURE SPECIFICATION</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 2.1 System Architecture Overview
    story.append(Paragraph("<b>2.1  System Architecture Overview</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    arch_ov = (
        "The RISC-V VeeR EL2 Based Sensor Monitoring and Signal Processing SoC is architected around a centralized "
        "AMBA AXI4-Lite crossbar interconnect that interfaces a 32-bit RISC-V core with high-performance memories "
        "and six specialized peripheral IP blocks. The architecture is engineered to provide complete hardware acceleration "
        "for the Acquire-Condition-Actuate control loop, minimizing CPU involvement to supervisory configuration and host telemetry."
    )
    story.append(Paragraph(arch_ov, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 2.2 Top-Level SoC Block Diagram & Bus Topology
    story.append(Paragraph("<b>2.2  Top-Level SoC Block Diagram & Bus Topology</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    fig_arch_path = os.path.join("reports", "figures", "soc_architecture_block_diagram.png")
    if os.path.exists(fig_arch_path):
        story.append(Image(fig_arch_path, width=6.5*72, height=4.1*72))
        story.append(Spacer(1, 4))
        story.append(Paragraph("<b>Figure 2.1:</b> Top-Level SoC Block Diagram and AXI4-Lite Bus Topology", styles['FigureCaption']))
        story.append(Spacer(1, 10))

    # 2.3 Complete IP Inventory & Detailed Block Specifications
    story.append(Paragraph("<b>2.3  Complete IP Inventory & Detailed Block Specifications</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    ip_intro = "The SoC integrates eleven major architectural blocks, combining the VeeR EL2 processor core with custom synthesizable IP modules:"
    story.append(Paragraph(ip_intro, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    ip_tbl_data = [
        [Paragraph("<b>IP Block</b>", styles['TableHdr']), Paragraph("<b>Source Module</b>", styles['TableHdr']), Paragraph("<b>Bus Role</b>", styles['TableHdr']), Paragraph("<b>Base Address</b>", styles['TableHdr']), Paragraph("<b>Primary Function</b>", styles['TableHdr'])],
        [Paragraph("VeeR EL2 Core", styles['TableBodyBold']), Paragraph("el2_veer_wrapper", styles['TableBody']), Paragraph("AXI4 Master", styles['TableBody']), Paragraph("0x0000_0000 (Rst)", styles['TableBody']), Paragraph("RV32IMC dual-issue core with PIC and CSRs", styles['TableBody'])],
        [Paragraph("LSU Bridge", styles['TableBodyBold']), Paragraph("axi4_to_axi4lite", styles['TableBody']), Paragraph("Protocol Adapter", styles['TableBody']), Paragraph("Direct (LSU to IC)", styles['TableBody']), Paragraph("Converts 64-bit AXI4 to 32-bit AXI4-Lite with burst split", styles['TableBody'])],
        [Paragraph("IFU Bridge", styles['TableBodyBold']), Paragraph("axi4_to_axi4lite_ro", styles['TableBody']), Paragraph("Read-Only Adapter", styles['TableBody']), Paragraph("Direct (IFU to IMEM)", styles['TableBody']), Paragraph("Read-only bridge feeding Port A of IMEM", styles['TableBody'])],
        [Paragraph("AXI Interconnect", styles['TableBodyBold']), Paragraph("axi4lite_interconnect", styles['TableBody']), Paragraph("1x9 Crossbar", styles['TableBody']), Paragraph("System Fabric", styles['TableBody']), Paragraph("Decodes 9 address apertures, routes read/write channels", styles['TableBody'])],
        [Paragraph("Register Shim", styles['TableBodyBold']), Paragraph("axi4lite_regif", styles['TableBody']), Paragraph("Slave Adapter", styles['TableBody']), Paragraph("Per-IP Shim", styles['TableBody']), Paragraph("Enforces 32-bit alignment and SLVERR on partial WSTRB", styles['TableBody'])],
        [Paragraph("Dual-Port IMEM", styles['TableBodyBold']), Paragraph("axi4lite_sram_dp", styles['TableBody']), Paragraph("AXI4-Lite Slave 0", styles['TableBody']), Paragraph("0x0000_0000", styles['TableBody']), Paragraph("32 KB Instruction Memory (Port A: IFU, Port B: LSU)", styles['TableBody'])],
        [Paragraph("Single-Port DMEM", styles['TableBodyBold']), Paragraph("axi4lite_sram", styles['TableBody']), Paragraph("AXI4-Lite Slave 1", styles['TableBody']), Paragraph("0x1000_0000", styles['TableBody']), Paragraph("32 KB Data Memory for stack, heap, and buffers", styles['TableBody'])],
        [Paragraph("UART Controller", styles['TableBodyBold']), Paragraph("uart", styles['TableBody']), Paragraph("AXI4-Lite Slave 2", styles['TableBody']), Paragraph("0x8000_0000", styles['TableBody']), Paragraph("8-N-1 UART with 16-byte TX/RX FIFOs and prescaler", styles['TableBody'])],
        [Paragraph("Machine Timer", styles['TableBodyBold']), Paragraph("timer", styles['TableBody']), Paragraph("AXI4-Lite Slave 3", styles['TableBody']), Paragraph("0x8000_1000", styles['TableBody']), Paragraph("64-bit mtime/mtimecmp timer with compare interrupt", styles['TableBody'])],
        [Paragraph("GPIO Controller", styles['TableBodyBold']), Paragraph("gpio", styles['TableBody']), Paragraph("AXI4-Lite Slave 4", styles['TableBody']), Paragraph("0x8000_2000", styles['TableBody']), Paragraph("16-bit bidir IO with edge/level interrupt generation", styles['TableBody'])],
        [Paragraph("I2C Controller", styles['TableBodyBold']), Paragraph("i2c_ctrl", styles['TableBody']), Paragraph("AXI4-Lite Slave 5", styles['TableBody']), Paragraph("0x8000_3000", styles['TableBody']), Paragraph("Master I2C with clock divider and open-drain buffers", styles['TableBody'])],
        [Paragraph("FIR Accelerator", styles['TableBodyBold']), Paragraph("fir_filter", styles['TableBody']), Paragraph("AXI4-Lite Slave 6", styles['TableBody']), Paragraph("0x8000_4000", styles['TableBody']), Paragraph("16-tap Q1.15 direct-form MAC with saturation clipping", styles['TableBody'])],
        [Paragraph("PWM Generator", styles['TableBodyBold']), Paragraph("pwm_gen", styles['TableBody']), Paragraph("AXI4-Lite Slave 7", styles['TableBody']), Paragraph("0x8000_5000", styles['TableBody']), Paragraph("Double-buffered PWM generator with polarity control", styles['TableBody'])],
        [Paragraph("Decode Error Slave", styles['TableBodyBold']), Paragraph("axi4lite_err_slave", styles['TableBody']), Paragraph("AXI4-Lite Slave 8", styles['TableBody']), Paragraph("Default Unmapped", styles['TableBody']), Paragraph("Captures unmapped address accesses and returns DECERR", styles['TableBody'])],
    ]
    t_ip = Table(ip_tbl_data, colWidths=[70, 85, 75, 80, 170])
    t_ip.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(Paragraph("<b>Table 2.1:</b> Complete IP Inventory and Functional Specifications", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_ip)
    story.append(Spacer(1, 10))

    # Detailed subsections
    story.append(Paragraph("<b>2.3.1  RISC-V Processor Core — VeeR EL2</b>", styles['SubSecHeading']))
    story.append(Spacer(1, 4))
    veer_desc = (
        "The core processing engine is the Western Digital / CHIPS Alliance VeeR EL2 (el2_veer_wrapper). "
        "Key architectural features include:<br/>"
        "• <b>RV32IMC Architecture:</b> Implements the unprivileged RISC-V RV32I base integer instruction set, standard "
        "M extension (hardware integer multiplier/divider), C extension (16-bit compressed instructions), and Zicsr CSRs.<br/>"
        "• <b>Dual-Issue Superscalar Pipeline:</b> 4-stage execution pipeline capable of retiring up to two instructions per clock cycle.<br/>"
        "• <b>Programmable Interrupt Controller (PIC):</b> Built-in interrupt controller servicing 8 external vectored interrupt "
        "sources (extintsrc_req[8:1]) from UART, Timer, I2C, FIR, PWM, and GPIO.<br/>"
        "• <b>External Memory Configuration:</b> Configured with internal ICCM and DCCM disabled, routing all instruction fetches "
        "and data transfers through the external AXI4 bus interfaces."
    )
    story.append(Paragraph(veer_desc, styles['BodyJustify']))
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>2.3.2  64-to-32 Bit AXI4-to-AXI4-Lite LSU Bridge (axi4_to_axi4lite)</b>", styles['SubSecHeading']))
    story.append(Spacer(1, 4))
    lsu_bridge_desc = (
        "The VeeR EL2 LSU natively outputs 64-bit wide AXI4 transactions. The custom LSU bridge translates these transfers "
        "into compliant 32-bit AXI4-Lite handshakes:<br/>"
        "• <b>Dynamic Lane Selection:</b> Evaluates address bit ADDR[2]. For lower-word transfers (+0x0), data is steered from "
        "LSU lanes [31:0]. For upper-word transfers (+0x4), data is steered from LSU lanes [63:32].<br/>"
        "• <b>Burst Splitting State Machine:</b> When the core issues multi-beat burst transfers (e.g. cache-line fills or block copies), "
        "an internal FSM splits the transaction into sequential single-beat AXI4-Lite transfers, incrementing the address after each handshake.<br/>"
        "• <b>Size Clamping:</b> Automatically clamps burst size from 3'b011 (8 bytes) to 3'b010 (4 bytes)."
    )
    story.append(Paragraph(lsu_bridge_desc, styles['BodyJustify']))
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>2.3.3  Hardware 16-Tap FIR Filter Accelerator (fir_filter.sv)</b>", styles['SubSecHeading']))
    story.append(Spacer(1, 4))
    fir_desc = (
        "The digital signal conditioning engine is a custom 16-tap direct-form FIR accelerator:<br/>"
        "• <b>Q1.15 Fixed-Point Arithmetic:</b> Operates on signed 16-bit fractional numbers (1 sign bit, 15 fractional bits).<br/>"
        "• <b>Internal Multiply-Accumulate Pipeline:</b> Features a 40-bit internal accumulator preventing intermediate overflow.<br/>"
        "• <b>Programmable Coefficient RAM:</b> Accommodates 16 programmable tap weights loaded during system boot.<br/>"
        "• <b>Automatic Saturation:</b> Clips accumulated outputs strictly to [-32768, 32767] and asserts a sticky SAT status flag upon overflow."
    )
    story.append(Paragraph(fir_desc, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 2.4 Interfacing Signals & Pinout Specification
    story.append(Paragraph("<b>2.4  Interfacing Signals & Pinout Specification</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))

    axi_sig_data = [
        [Paragraph("<b>Signal Name</b>", styles['TableHdr']), Paragraph("<b>Direction</b>", styles['TableHdr']), Paragraph("<b>Width</b>", styles['TableHdr']), Paragraph("<b>Description</b>", styles['TableHdr'])],
        [Paragraph("aclk", styles['TableBodyBold']), Paragraph("Input", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Global system clock (50 MHz / 100 MHz)", styles['TableBody'])],
        [Paragraph("aresetn", styles['TableBodyBold']), Paragraph("Input", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Active-low synchronized system reset", styles['TableBody'])],
        [Paragraph("awaddr[31:0]", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("32", styles['TableBody']), Paragraph("Write address bus carrying target register offset", styles['TableBody'])],
        [Paragraph("awvalid", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write address valid handshake flag", styles['TableBody'])],
        [Paragraph("awready", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write address ready acknowledgement", styles['TableBody'])],
        [Paragraph("wdata[31:0]", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("32", styles['TableBody']), Paragraph("Write payload data bus", styles['TableBody'])],
        [Paragraph("wstrb[3:0]", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("4", styles['TableBody']), Paragraph("Write byte strobes (must be 4'b1111 for valid access)", styles['TableBody'])],
        [Paragraph("wvalid", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write data valid handshake flag", styles['TableBody'])],
        [Paragraph("wready", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write data ready acknowledgement", styles['TableBody'])],
        [Paragraph("bresp[1:0]", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("2", styles['TableBody']), Paragraph("Write response: 2'b00=OKAY, 2'b10=SLVERR, 2'b11=DECERR", styles['TableBody'])],
        [Paragraph("bvalid", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write response valid indicator", styles['TableBody'])],
        [Paragraph("bready", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Write response ready indicator", styles['TableBody'])],
        [Paragraph("araddr[31:0]", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("32", styles['TableBody']), Paragraph("Read address bus carrying target register offset", styles['TableBody'])],
        [Paragraph("arvalid", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Read address valid handshake flag", styles['TableBody'])],
        [Paragraph("arready", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Read address ready acknowledgement", styles['TableBody'])],
        [Paragraph("rdata[31:0]", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("32", styles['TableBody']), Paragraph("Read data bus carrying retrieved register value", styles['TableBody'])],
        [Paragraph("rresp[1:0]", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("2", styles['TableBody']), Paragraph("Read response: 2'b00=OKAY, 2'b10=SLVERR, 2'b11=DECERR", styles['TableBody'])],
        [Paragraph("rvalid", styles['TableBodyBold']), Paragraph("Slave → Master", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Read data valid indicator", styles['TableBody'])],
        [Paragraph("rready", styles['TableBodyBold']), Paragraph("Master → Slave", styles['TableBody']), Paragraph("1", styles['TableBody']), Paragraph("Read data ready indicator", styles['TableBody'])],
    ]
    t_axi = Table(axi_sig_data, colWidths=[90, 80, 45, 265])
    t_axi.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 2.2:</b> AMBA AXI4-Lite Bus Interface Signal Definitions", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_axi)
    story.append(Spacer(1, 10))

    # Table 2.3 Physical Pinout
    pin_data = [
        [Paragraph("<b>Signal Name</b>", styles['TableHdr']), Paragraph("<b>Source</b>", styles['TableHdr']), Paragraph("<b>Destination</b>", styles['TableHdr']), Paragraph("<b>Description & Role</b>", styles['TableHdr'])],
        [Paragraph("uart_tx", styles['TableBodyBold']), Paragraph("uart", styles['TableBody']), Paragraph("External Pin", styles['TableBody']), Paragraph("Serial telemetry output at 115200 baud (8-N-1)", styles['TableBody'])],
        [Paragraph("uart_rx", styles['TableBodyBold']), Paragraph("External Pin", styles['TableBody']), Paragraph("uart", styles['TableBody']), Paragraph("Serial command / telemetry input pin", styles['TableBody'])],
        [Paragraph("i2c_scl", styles['TableBodyBold']), Paragraph("i2c_ctrl", styles['TableBody']), Paragraph("External Pad (Inout)", styles['TableBody']), Paragraph("I2C serial clock with open-drain pull-up modeling", styles['TableBody'])],
        [Paragraph("i2c_sda", styles['TableBodyBold']), Paragraph("i2c_ctrl", styles['TableBody']), Paragraph("External Pad (Inout)", styles['TableBody']), Paragraph("I2C bidirectional serial data line", styles['TableBody'])],
        [Paragraph("pwm_out[0]", styles['TableBodyBold']), Paragraph("pwm_gen", styles['TableBody']), Paragraph("External Pin", styles['TableBody']), Paragraph("Duty-cycle-modulated actuator output drive signal", styles['TableBody'])],
        [Paragraph("gpio[15:0]", styles['TableBodyBold']), Paragraph("gpio", styles['TableBody']), Paragraph("External Pad (Inout)", styles['TableBody']), Paragraph("16-bit general-purpose bidirectional digital IO pins", styles['TableBody'])],
        [Paragraph("irq_uart", styles['TableBodyBold']), Paragraph("uart", styles['TableBody']), Paragraph("Core PIC (irq[1])", styles['TableBody']), Paragraph("UART RX data ready / TX FIFO empty interrupt", styles['TableBody'])],
        [Paragraph("irq_timer", styles['TableBodyBold']), Paragraph("timer", styles['TableBody']), Paragraph("Core PIC (irq[2])", styles['TableBody']), Paragraph("Machine timer compare match interrupt (mtime >= mtimecmp)", styles['TableBody'])],
        [Paragraph("irq_i2c", styles['TableBodyBold']), Paragraph("i2c_ctrl", styles['TableBody']), Paragraph("Core PIC (irq[3])", styles['TableBody']), Paragraph("I2C byte transfer complete interrupt", styles['TableBody'])],
        [Paragraph("irq_fir", styles['TableBodyBold']), Paragraph("fir_filter", styles['TableBody']), Paragraph("Core PIC (irq[4])", styles['TableBody']), Paragraph("FIR filtered sample computation done interrupt", styles['TableBody'])],
        [Paragraph("irq_pwm", styles['TableBodyBold']), Paragraph("pwm_gen", styles['TableBody']), Paragraph("Core PIC (irq[5])", styles['TableBody']), Paragraph("PWM counter period rollover interrupt", styles['TableBody'])],
        [Paragraph("irq_gpio", styles['TableBodyBold']), Paragraph("gpio", styles['TableBody']), Paragraph("Core PIC (irq[6])", styles['TableBody']), Paragraph("GPIO configured pin edge/level interrupt", styles['TableBody'])],
    ]
    t_pin = Table(pin_data, colWidths=[80, 70, 110, 220])
    t_pin.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f1f3f4")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#bdc1c6")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(Paragraph("<b>Table 2.3:</b> Top-Level SoC Physical Pinout and External Interrupt Signals", styles['TableCaption']))
    story.append(Spacer(1, 4))
    story.append(t_pin)
    story.append(Spacer(1, 10))

    # 2.5 Control Path Specification
    story.append(Paragraph("<b>2.5  Control Path Specification</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    cp_text = (
        "The control path coordinates bus arbitration, transaction boundary locking, and fault trapping:<br/>"
        "• <b>Non-Blocking Fetch vs Load/Store:</b> The VeeR EL2 core fetches instructions over Port A of Dual-Port IMEM "
        "via axi4_to_axi4lite_ro without traversing the peripheral interconnect. LSU transactions exclusively access the "
        "crossbar, preventing bus contention between program fetches and sensor I/O accesses.<br/>"
        "• <b>Strict Alignment Enforcement:</b> All peripheral accesses require 32-bit aligned addresses (ADDR[1:0] == 2'b00). "
        "Unaligned memory accesses trigger an immediate SLVERR response, generating a precise trap in the CPU.<br/>"
        "• <b>Byte Strobe Validation:</b> Peripherals accept writes only with full byte strobes (WSTRB == 4'b1111). Partial writes "
        "(e.g. byte or half-word writes to peripheral registers) return SLVERR (bresp = 2'b10).<br/>"
        "• <b>Unmapped Hole Trapping:</b> Unmapped addresses in the memory space are routed to axi4lite_err_slave, which immediately "
        "terminates the transaction with DECERR (2'b11)."
    )
    story.append(Paragraph(cp_text, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 2.6 Data Path Specification
    story.append(Paragraph("<b>2.6  Data Path Specification: The Closed-Loop Pipeline</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    dp_text = (
        "The end-to-end telemetry pipeline operates as a deterministic, closed-loop control system:<br/>"
        "<b>1. Step 1 — Sensor Ingestion (I2C):</b> The CPU programs the I2C Master to poll the external sensor (address 0x48). "
        "The I2C core executes the START, address, and data phases, latching the 16-bit raw signed measurement.<br/>"
        "<b>2. Step 2 — Hardware Conditioning (FIR):</b> The CPU reads the raw sample and writes it to FIR DATA_IN (0x8000_4008). "
        "The FIR accelerator shifts the delay line, executes 16 MAC operations across Q1.15 coefficients, and asserts DONE.<br/>"
        "<b>3. Step 3 — Closed-Loop Actuation (PWM):</b> The smoothed sample is read from FIR DATA_OUT (0x8000_400C) and mapped "
        "linearly to duty cycle: <i>duty = ((filt + 32768) * (PERIOD + 1)) >> 16</i>. The CPU writes this value to PWM DUTY (0x8000_5008), "
        "which reloads cleanly on counter rollover.<br/>"
        "<b>4. Step 4 — Host Telemetry (UART):</b> Processed iteration count, raw sample, filtered sample, and duty cycle are formatted "
        "into telemetry strings and streamed across UART at 115200 baud.<br/>"
        "<b>5. Step 5 — Cadence Supervision (Timer):</b> The 64-bit Machine Timer regulates the sampling period (1 ms cadence), "
        "asserting timer_irq to trigger the subsequent acquisition cycle."
    )
    story.append(Paragraph(dp_text, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    callout_timing = (
        "Operating at a core clock frequency of 50 MHz (Tclk = 20 ns), a 16-tap FIR computation completes in exactly "
        "16 clock cycles (320 ns), delivering over 3.125 Mega-samples/sec processing throughput. A full closed-loop "
        "acquisition-filter-actuate cycle resolves in under 25 us, leaving >97% of the 1 ms sampling window idle for "
        "telemetry serialization and background supervisory tasks."
    )
    story.append(make_callout_box("TIMING & PERFORMANCE BUDGET", callout_timing, styles))
    story.append(PageBreak())

    # =============================================================
    # CHAPTER 3: GITHUB ACCOUNT STEPS
    # =============================================================
    story.append(Paragraph("<b>Chapter 3</b>", styles['ChapNumber']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>GITHUB ACCOUNT STEPS</b>", styles['ChapTitle']))
    story.append(Spacer(1, 14))

    # 3.1 Version Control in Safety-Critical EDA Projects
    story.append(Paragraph("<b>3.1  Version Control in Safety-Critical EDA Projects</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    vc_text = (
        "In modern System-on-Chip design and ASIC/FPGA engineering, rigorous revision control is indispensable "
        "for design traceability, regression test reproducibility, and collaborative verification. For this project, all synthesizable "
        "RTL modules, bare-metal C drivers, firmware binaries, verification testbenches, and UVM 1.2 Verification IPs (VIPs) "
        "are version-controlled using Git and hosted on GitHub under the repository:<br/>"
        f"<b><font color='#1a73e8'>{GITHUB_REPO_URL}</font></b>"
    )
    story.append(Paragraph(vc_text, styles['BodyJustify']))
    story.append(Spacer(1, 10))

    # 3.2 GitHub Account Creation & Secure Authentication Setup
    story.append(Paragraph("<b>3.2  GitHub Account Creation & Secure Authentication Setup</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    auth_text = (
        "To establish secure, automated communication between the local EDA workstation and GitHub without exposing plain passwords, "
        "cryptographic SSH key-pairs (Ed25519) and the GitHub CLI credential helper are configured.<br/><br/>"
        "<b>Step 1: Account Setup:</b> The GitHub account <b>AkshaySai06</b> was registered and secured with Two-Factor Authentication (2FA).<br/>"
        "<b>Step 2: SSH Key Generation:</b> An elliptic-curve Ed25519 key-pair was generated and added to the SSH agent."
    )
    story.append(Paragraph(auth_text, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    l31_code = (
        "# 1. Generate modern Ed25519 SSH key-pair\n"
        "ssh-keygen -t ed25519 -C \"akshay@example.com\"\n"
        "# 2. Start SSH agent in background\n"
        "eval \"$(ssh-agent -s)\"\n"
        "# 3. Add private key to agent\n"
        "ssh-add ~/.ssh/id_ed25519\n"
        "# 4. Display public key for GitHub registration\n"
        "cat ~/.ssh/id_ed25519.pub"
    )
    story.append(make_code_box("3.1: SSH Key Generation and Agent Registration", l31_code, styles))
    story.append(Spacer(1, 6))

    l32_code = (
        "# Verify SSH connection to GitHub\n"
        "ssh -T git@github.com\n"
        "# Expected response:\n"
        "# Hi AkshaySai06! You've successfully authenticated..."
    )
    story.append(make_code_box("3.2: SSH Connection Verification", l32_code, styles))
    story.append(Spacer(1, 10))

    # 3.3 Repository Initialization and Remote Configuration
    story.append(Paragraph("<b>3.3  Repository Initialization and Remote Configuration</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l33_code = (
        "# 1. Configure global Git identity\n"
        "git config --global user.name \"Akshay\"\n"
        "git config --global user.email \"akshay@example.com\"\n"
        "git config --global init.defaultBranch main\n\n"
        "# 2. Navigate to project root & initialize repository\n"
        "cd /home/student/Documents/akshay_honours/Honours_project\n"
        "git init -b main\n\n"
        "# 3. Link remote GitHub repository\n"
        "git remote add origin https://github.com/AkshaySai06/RISC-V-VeeR-EL2-Based-Sensor-Monitoring-and-Signal-Processing-SoC.git\n"
        "git remote -v"
    )
    story.append(make_code_box("3.3: Git Initialization and Remote Association", l33_code, styles))
    story.append(Spacer(1, 10))

    # 3.4 EDA-Specific .gitignore Configuration
    story.append(Paragraph("<b>3.4  EDA-Specific .gitignore Configuration</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    gi_text = (
        "Electronic Design Automation (EDA) tools — particularly Synopsys VCS and Verdi — generate multi-gigabyte "
        "binary compilation trees, object databases, and uncompressed simulation waveforms. Crucially, during simulation, "
        "an uncompressed waveform dump (uart_verification.vcd) grew to <b>4.29 GB</b>. Because GitHub strictly enforces "
        "a 100 MB maximum single-file upload limit, committing this file would permanently block git push operations. "
        "A customized .gitignore was implemented to filter all transient EDA and build artifacts:"
    )
    story.append(Paragraph(gi_text, styles['BodyJustify']))
    story.append(Spacer(1, 6))

    l34_code = (
        "# VCS / EDA Simulation Binaries & Compile Artifacts\n"
        "sim/simv*\n"
        "sim/csrc/\n"
        "sim/*.daidir/\n"
        "sim/verdiLog/\n"
        "sim/vcd2fsdbLog/\n"
        "soc_uvm/sim/simv*\n"
        "soc_uvm/sim/csrc/\n"
        "soc_uvm/sim/*.daidir/\n"
        "soc_uvm/sim/verdiLog/\n"
        "soc_uvm/sim/vcd2fsdbLog/\n"
        "*.so\n"
        "ucli.key\n"
        "novas.conf\n"
        "novas.rc\n\n"
        "# Waveform Dumps (uart_verification.vcd is 4.3 GB, exceeding GitHub 100MB limit)\n"
        "*.vcd\n"
        "*.vpd\n"
        "*.fsdb\n"
        "*.wlf\n\n"
        "# Intermediate Object Files\n"
        "*.o\n"
        "*.elf"
    )
    story.append(make_code_box("3.4: Project .gitignore for Synopsys VCS & EDA Builds", l34_code, styles))
    story.append(Spacer(1, 10))

    # 3.5 Day-to-Day Development & Collaboration Workflow
    story.append(Paragraph("<b>3.5  Day-to-Day Development & Collaboration Workflow</b>", styles['SecHeading']))
    story.append(Spacer(1, 6))
    l35_code = (
        "# Inspect repository commit status and history\n"
        "git log --oneline -n 1\n"
        "# Output:\n"
        f"# {COMMIT_HASH} Initial commit: RISC-V VeeR-EL2 based Sensor Monitoring and Signal Processing SoC\n\n"
        "# Verified 1,224 files staged and pushed cleanly (277,301 insertions) across main branch."
    )
    story.append(make_code_box("3.5: Verified Project Git Commit History", l35_code, styles))
    story.append(PageBreak())

    return story
