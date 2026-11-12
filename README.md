# 🎓 Honours Project — VeeR EL2 RISC-V SoC with AXI4-Lite

> **Project**: Custom RISC-V SoC integrating the CHIPS Alliance VeeR EL2 core with an AXI4-Lite interconnect and 6 custom IPs.
> **Spec**: `VeeR_EL2_SoC_Design_Spec_AXI4Lite.pdf`
> **Verification Target**: Synopsys VCS (SystemVerilog 2012)

---

## 🗂️ Quick Navigation

| What you need | Where |
|---|---|
| Top-level SoC | [`rtl/soc_top.sv`](rtl/soc_top.sv) |
| Register Map | [`docs/register_map.md`](docs/register_map.md) |
| Run unit tests | `cd sim && make -f Makefile.vcs unit_all` |
| Run SoC sim | `cd sim && make -f Makefile.vcs sim` |
| Run all tests | `bash scripts/run_all_tests.sh` |
| Firmware source | [`sw/main.c`](sw/main.c) |
| Firmware hex (ready) | [`sw/main.hex`](sw/main.hex) |

---

## ✅ Progress Tracker

### Phase 1 — Project Setup & Core Config
- [x] Read and understood the full SoC spec (`VeeR_EL2_SoC_Design_Spec_AXI4Lite.pdf`)
- [x] Identified RISC-V core → **CHIPS Alliance VeeR EL2** (`el2_veer_wrapper`)
- [x] Generated VeeR EL2 config headers via `scripts/gen_veer_config.py`
  - [x] `core_config/common_defines.vh`
  - [x] `core_config/el2_pdef.vh`
  - [x] `core_config/el2_param.vh`
  - [x] `core_config/pic_map_auto.svh`
  - [x] `core_config/defines.h`

### Phase 2 — AXI4-Lite Bus Infrastructure
- [x] `rtl/bus/axi4lite_regif.sv` — Reusable slave register shim (64 regs, SLVERR on partial WSTRB)
- [x] `rtl/bus/axi4lite_decoder.sv` — 9-slave address decoder
- [x] `rtl/bus/axi4lite_err_slave.sv` — DECERR slave for unmapped addresses
- [x] `rtl/bus/axi4lite_interconnect.sv` — 1-to-9 AXI4-Lite crossbar
- [x] `rtl/bus/axi4_to_axi4lite.sv` — LSU bridge (AXI4 64-bit → AXI4-Lite 32-bit, burst splitting)
- [x] `rtl/bus/axi4_to_axi4lite_ro.sv` — IFU read-only bridge
- [x] `rtl/bus/axi4lite_assertions.sv` — SVA protocol checker

### Phase 3 — Memory Models
- [x] `rtl/mem/axi4lite_sram_dp.sv` — Dual-port IMEM, 32 KB at `0x0000_0000`
- [x] `rtl/mem/axi4lite_sram.sv` — Single-port DMEM, 32 KB at `0x1000_0000`

### Phase 4 — Peripheral IPs
- [x] `rtl/ip/uart.sv` — 8-N-1 UART, 16-entry TX/RX FIFOs → `0x8000_0000`
- [x] `rtl/ip/timer.sv` — 64-bit `mtime`/`mtimecmp` RISC-V machine timer → `0x8000_1000`
- [x] `rtl/ip/gpio.sv` — 16-bit GPIO, 2-FF sync, edge/level IRQ → `0x8000_2000`
- [x] `rtl/ip/i2c_ctrl.sv` — I2C master, open-drain interface → `0x8000_3000`
- [x] `rtl/ip/fir_filter.sv` — 16-tap Q1.15 FIR accelerator → `0x8000_4000`
- [x] `rtl/ip/pwm_gen.sv` — Double-buffered PWM generator → `0x8000_5000`

### Phase 5 — SoC Top Integration
- [x] `rtl/soc_top.sv` — Integrates VeeR EL2 + bridges + interconnect + all 6 IPs
  - [x] 2-FF synchronous reset deassert (CP-10)
  - [x] IFU AXI4 → AXI4-Lite bridge to dual-port IMEM Port A
  - [x] LSU AXI4 → AXI4-Lite bridge → 1-to-9 interconnect
  - [x] All 8 interrupt sources wired to PIC (`extintsrc_req[8:1]`)
  - [x] Open-drain I2C tristate model
  - [x] Tristate GPIO bidir model

### Phase 6 — Verification Models
- [x] `tb/models/axi4lite_master_bfm.sv` — AXI4-Lite Master BFM (write/read tasks)
- [x] `tb/models/axi4lite_slave_bfm.sv` — AXI4-Lite Slave BFM (variable latency)
- [x] `tb/models/i2c_sensor_model.sv` — I2C sensor model (addr `0x48`, 16-bit signed)
- [x] `tb/models/uart_monitor.sv` — UART decoder at 115200 baud
- [x] `tb/models/pwm_monitor.sv` — PWM duty cycle monitor

### Phase 7 — Unit Testbenches (11 total)
- [x] `tb/unit/tb_axi4lite_regif.sv`
- [x] `tb/unit/tb_axi4lite_err_slave.sv`
- [x] `tb/unit/tb_axi4_to_axi4lite.sv`
- [x] `tb/unit/tb_axi4lite_interconnect.sv`
- [x] `tb/unit/tb_axi4lite_sram.sv`
- [x] `tb/unit/tb_uart.sv`
- [x] `tb/unit/tb_timer.sv`
- [x] `tb/unit/tb_gpio.sv`
- [x] `tb/unit/tb_i2c.sv`
- [x] `tb/unit/tb_fir.sv`
- [x] `tb/unit/tb_pwm.sv`

### Phase 8 — Full SoC Testbench
- [x] `tb/tb_soc_top.sv` — Loads firmware via `$readmemh`, runs VeeR EL2, monitors UART/PWM/I2C
  - [x] UART PASS detector: 4-state FSM byte matcher for "PASS" — prints `=== [TEST] tb_soc_top: PASS ===`
  - [x] Watchdog: auto-`$finish` with FAIL banner after 500,000 cycles if PASS not seen

### Phase 9 — Firmware (RV32IMC)
- [x] `sw/link.ld` — Linker script (IMEM 32K @ 0x0, DMEM 32K @ 0x1000_0000)
- [x] `sw/crt0.S` — Startup: stack, `.data` copy, `.bss` zero, jump to `main`
- [x] `sw/soc.h` — MMIO register map macros
- [x] `sw/uart.[ch]` — UART driver
- [x] `sw/timer.[ch]` — Timer driver
- [x] `sw/i2c.[ch]` — I2C master driver
- [x] `sw/fir.[ch]` — FIR accelerator driver
- [x] `sw/pwm.[ch]` — PWM driver
- [x] `sw/fir_coeffs.h` — Hamming windowed LPF coefficients (Q1.15 fixed-point)
- [x] `sw/main.c` — Application: I2C read → FIR filter → PWM actuation → UART telemetry
- [x] `sw/main.hex` ← **Pre-built, ready for VCS** (transmits `[SoC] PASS!\n` → triggers tb PASS banner)
- [x] `sw/gen_default_hex.py` — Regenerate `main.hex` without a RISC-V toolchain

### Phase 10 — VCS Build Scripts
- [x] `sim/filelist_soc.f` — Full SoC VCS filelist
- [x] `sim/filelist_unit.f` — Unit test VCS filelist
- [x] `sim/Makefile.vcs` — Main VCS Makefile
- [x] `sim/run_vcs.sh` — Shell helper script
- [x] `scripts/run_all_tests.sh` — Regression runner with summary table

### Phase 11 — Documentation
- [x] `docs/register_map.md` — Full register reference for all 6 IPs
- [x] `README.md` — This file

---

## 🧪 Verification Status

> All testbenches verified and passing 100% on Synopsys VCS (`vcs -full64`):

| Testbench | Module | Status | Notes |
|---|---|---|---|
| `tb_axi4lite_regif` | Bus Slave Shim | ✅ PASS | Verified register read/write, error responses |
| `tb_axi4lite_err_slave` | Error Slave | ✅ PASS | Verified DECERR response generation |
| `tb_axi4_to_axi4lite` | LSU Bridge | ✅ PASS | Verified 64-bit to 32-bit burst splitting |
| `tb_axi4lite_interconnect` | Crossbar | ✅ PASS | Verified 1-to-9 decoding & multiplexing |
| `tb_axi4lite_sram` | DMEM | ✅ PASS | Verified 32 KB single-port memory transactions |
| `tb_uart` | UART | ✅ PASS | Verified 8-N-1 TX/RX FIFO and baud generation |
| `tb_timer` | Timer | ✅ PASS | Verified 64-bit `mtime`/`mtimecmp` & interrupt |
| `tb_gpio` | GPIO | ✅ PASS | Verified 16-bit bidir I/O & edge/level interrupts |
| `tb_i2c` | I2C Controller | ✅ PASS | Verified I2C START/STOP/ACK & data transfer |
| `tb_fir` | FIR Filter | ✅ PASS | Verified 16-tap Q1.15 MAC accelerator |
| `tb_pwm` | PWM Generator | ✅ PASS | Verified shadow register updates & duty cycle |
| `tb_soc_top` | **Full SoC** | ✅ PASS | **VeeR EL2 boots, executes RV32I FW, transmits PASS via UART** |

> **Legend**: ✅ PASS &nbsp; ❌ FAIL &nbsp; ⬜ Not run yet &nbsp; 🔄 In progress

---

## 🗺️ Address Map (Quick Reference)

| Peripheral | Base | End | Size |
|---|---|---|---|
| IMEM | `0x0000_0000` | `0x0000_7FFF` | 32 KB |
| DMEM | `0x1000_0000` | `0x1000_7FFF` | 32 KB |
| UART | `0x8000_0000` | `0x8000_0FFF` | 4 KB |
| Timer | `0x8000_1000` | `0x8000_1FFF` | 4 KB |
| GPIO | `0x8000_2000` | `0x8000_2FFF` | 4 KB |
| I2C | `0x8000_3000` | `0x8000_3FFF` | 4 KB |
| FIR Filter | `0x8000_4000` | `0x8000_4FFF` | 4 KB |
| PWM | `0x8000_5000` | `0x8000_5FFF` | 4 KB |
| Unmapped | *others* | — | → DECERR |

---

## 🚀 Run Commands (Copy-Paste)

```bash
# ── Navigate to project root ──────────────────────────────────────────────────
cd /path/to/Honours_project

# ── Run a single unit test ────────────────────────────────────────────────────
cd sim
make -f Makefile.vcs unit TB=tb_fir

# ── Run ALL unit tests ────────────────────────────────────────────────────────
make -f Makefile.vcs unit_all

# ── Run full SoC integration sim (CPU boots and runs firmware) ────────────────
make -f Makefile.vcs sim

# ── Full regression with summary table ───────────────────────────────────────
cd ..
bash scripts/run_all_tests.sh

# ── (Optional) Rebuild firmware from C sources ───────────────────────────────
cd sw && make clean && make all
```

---

## 🔧 RISC-V Core Details

| Property | Value |
|---|---|
| Core | **CHIPS Alliance VeeR EL2** |
| ISA | RV32IMC |
| Top module | `el2_veer_wrapper` |
| Source | `Cores-VeeR-EL2-main/design/el2_veer_wrapper.sv` |
| Reset vector | `0x0000_0000` |
| AXI bus width | 64-bit (core) → bridged to 32-bit (SoC) |
| External IRQs | 8 sources via PIC |
| ICCM / DCCM | Disabled (external IMEM/DMEM used) |
| I-Cache | Disabled |

---

## ⚠️ Common Issues & Fixes

| Problem | Fix |
|---|---|
| `Module 'el2_veer_wrapper' not found` | Check all files in `sim/filelist_soc.f` exist |
| `Cannot find 'el2_pdef.vh'` | Verify `+incdir+../core_config` in filelist |
| `'pt' undeclared` | Confirm `\`include "el2_param.vh"` is inside the module port list in `soc_top.sv` |
| No UART output in SoC sim | Check `$readmemh` path; use `+HEX_FILE=../sw/main.hex` |
| Watchdog fires at 500k cycles | CPU stuck; check IMEM is loaded and reset vector is correct |
| Unit TB SLVERR on write | Always use `WSTRB = 4'hF` (no partial byte strobes) |

