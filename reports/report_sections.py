# -*- coding: utf-8 -*-
"""
report_sections.py
Master repository of technical content, tables, and code listings for:
RISC-V VeeR EL2 Based Sensor Monitoring and Signal Processing SoC
Submitted by: Veeramalla Akshay (Roll No: 1602-23-735-130)
Supervisor: Dr. M. Praveen Kumar, Assistant Professor, Dept of ECE
HOD: Dr. E. Sreenivasa Rao, Professor & Head, Dept of ECE
Vasavi College of Engineering (Autonomous), Hyderabad
"""

PROJECT_TITLE = "RISC-V VeeR EL2 BASED SENSOR MONITORING AND SIGNAL PROCESSING SoC"
CANDIDATE_NAME = "Veeramalla Akshay"
ROLL_NO = "1602-23-735-130"
SUPERVISOR_NAME = "Dr. M. Praveen Kumar"
SUPERVISOR_TITLE = "Assistant Professor"
HOD_NAME = "Dr. E. Sreenivasa Rao"
HOD_TITLE = "Professor and Head"
COLLEGE_NAME = "VASAVI COLLEGE OF ENGINEERING (AUTONOMOUS)"
DEPARTMENT_NAME = "DEPARTMENT OF ELECTRONICS AND COMMUNICATION ENGINEERING"
COLLEGE_ADDRESS = "Ibrahimbagh, Hyderabad – 500031, Telangana, India"
ACADEMIC_YEAR = "ACADEMIC YEAR 2026 – 2027"
DATE_STR = "21st November, 2026"
GITHUB_REPO_URL = "https://github.com/AkshaySai06/RISC-V-VeeR-EL2-Based-Sensor-Monitoring-and-Signal-Processing-SoC"
GITHUB_USER = "AkshaySai06"
COMMIT_HASH = "c21f845"

ABSTRACT_TEXT = (
    "This Honours Course Based Project report documents the architectural design, RTL integration, "
    "bare-metal RISC-V firmware development, and UVM 1.2 functional verification of a high-performance "
    "RISC-V System-on-Chip (SoC) engineered for autonomous sensor monitoring, hardware signal conditioning, "
    "and closed-loop actuation in cyber-physical embedded systems. Built around the open-source CHIPS Alliance / "
    "Western Digital VeeR EL2 RV32IMC dual-issue superscalar processor core, the SoC implements a complete "
    "hardware-accelerated Acquire-Condition-Actuate pipeline that eliminates software polling overheads and CPU execution jitter.\n\n"
    "The system architecture integrates a centralized 1-to-9 AMBA AXI4-Lite crossbar interconnect (axi4lite_interconnect), "
    "a 64-to-32 bit Load/Store Unit (LSU) protocol bridge (axi4_to_axi4lite) featuring dynamic bus lane steering and burst splitting, "
    "an Instruction Fetch Unit (IFU) read-only bridge (axi4_to_axi4lite_ro), a 32 KB Dual-Port Instruction Memory (IMEM) "
    "supporting simultaneous CPU instruction fetches and bus slave programming, a 32 KB Single-Port Data Memory (DMEM), "
    "and six memory-mapped peripheral subsystems. These include a hardware I2C Master controller with open-drain buffers "
    "for external sensor acquisition, a custom 16-tap Direct-Form FIR Filter accelerator operating in Q1.15 fixed-point arithmetic "
    "with automatic saturation clipping, a double-buffered PWM generator with programmable prescaler and glitch-free reload "
    "for proportional actuation, an 8-N-1 UART controller with 16-byte TX/RX FIFOs for host telemetry, a 64-bit RISC-V Machine Timer "
    "(mtime/mtimecmp) for deterministic sampling cadence, and a 16-bit bidirectional GPIO controller with edge/level interrupt generation. "
    "A standardized, reusable AXI4-Lite slave register interface (axi4lite_regif) ensures strict 32-bit alignment and enforces SLVERR "
    "trapping on partial byte strobes, while an error slave (axi4lite_err_slave) routes all unmapped addresses to DECERR.\n\n"
    "The firmware architecture features a bare-metal C control loop executing from IMEM and utilizing DCCM stack frames. It orchestrates "
    "sensor sampling over I2C, offloads digital filtering to the hardware FIR accelerator, maps smoothed samples to PWM duty cycles, and streams "
    "telemetry packets over UART. Functional verification was executed in Synopsys VCS and Verdi across 11 standalone unit testbenches "
    "and a comprehensive UVM 1.2 environment incorporating six custom Verification IPs (FIR, GPIO, I2C, PWM, Timer, and UART VIPs). "
    "Cycle-accurate waveform traces confirm 100% test pass rate, zero bus deadlocks, single-cycle register accesses, and clean UART PASS "
    "signature transmission (=== [TEST] tb_soc_top: PASS ===)."
)
