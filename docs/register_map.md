# VeeR EL2 SoC Register Map Specification

This document details the register definitions, bit fields, access permissions, and reset values for all peripherals integrated into the VeeR EL2 SoC, compliant with the *VeeR EL2 SoC Design Specification with AXI4-Lite Interconnect* (v2.0).

---

## 1. System Memory Map Overview

| Peripheral / Memory | Base Address   | End Address    | Size   | Bus Protocol | Description |
|---------------------|----------------|----------------|--------|--------------|-------------|
| **IMEM (Dual-Port)**| `0x0000_0000`  | `0x0000_7FFF`  | 32 KB  | AXI4-Lite    | Instruction Memory (Port A: IFU direct fetch, Port B: Interconnect) |
| **DMEM**            | `0x1000_0000`  | `0x1000_7FFF`  | 32 KB  | AXI4-Lite    | Data Memory (LSU load/store) |
| **UART**            | `0x8000_0000`  | `0x8000_0FFF`  | 4 KB   | AXI4-Lite    | 8-N-1 UART with 16-byte TX/RX FIFOs |
| **TIMER**           | `0x8000_1000`  | `0x8000_1FFF`  | 4 KB   | AXI4-Lite    | 64-bit `mtime`/`mtimecmp` RISC-V Machine Timer |
| **GPIO**            | `0x8000_2000`  | `0x8000_2FFF`  | 4 KB   | AXI4-Lite    | 16-bit Bidirectional GPIO with Edge/Level Interrupts |
| **I2C Controller**  | `0x8000_3000`  | `0x8000_3FFF`  | 4 KB   | AXI4-Lite    | Master I2C Interface with Open-Drain Buffer |
| **FIR Filter**      | `0x8000_4000`  | `0x8000_4FFF`  | 4 KB   | AXI4-Lite    | 16-tap Direct-Form FIR Accelerator (Q1.15) |
| **PWM Generator**   | `0x8000_5000`  | `0x8000_5FFF`  | 4 KB   | AXI4-Lite    | Double-Buffered PWM Generator with Prescaler |
| **Unmapped Space**  | *All Others*   | *All Others*   | -      | AXI4-Lite    | Routed to `axi4lite_err_slave`, returns `DECERR` (2'b11) |

> **Note on Bus Rules:**
> - All peripheral accesses must use 32-bit aligned addresses (`ADDR[1:0] == 2'b00`) and full byte strobes (`WSTRB == 4'b1111`).
> - Writes with partial strobes (`WSTRB != 4'b1111`) are rejected and return `SLVERR` (`2'b10`).
> - Unmapped addresses return `DECERR` (`2'b11`).

---

## 2. UART Controller (`0x8000_0000`)

### Register Summary
| Offset | Name      | Access | Reset Value   | Description |
|--------|-----------|--------|---------------|-------------|
| `0x00` | `DATA`    | RW     | `0x0000_0000` | Write: TX FIFO data; Read: RX FIFO data |
| `0x04` | `STATUS`  | RO     | `0x0000_0006` | Status flags (TX Empty=1, RX Empty=1) |
| `0x08` | `BAUDDIV` | RW     | `0x0000_0036` | Baud rate divisor ($F_{sys} / (16 \times Baud) - 1$) |
| `0x0C` | `CTRL`    | RW     | `0x0000_0003` | Control register (TX_EN=1, RX_EN=1) |

### Bitfield Details
- **`DATA` (0x00)**:
  - `[7:0]`: `DATA` - 8-bit character data written to TX FIFO or popped from RX FIFO.
- **`STATUS` (0x04)**:
  - `[0]`: `TX_FULL` - TX FIFO is full (1) or has space (0).
  - `[1]`: `TX_EMPTY` - TX FIFO is completely empty (1).
  - `[2]`: `RX_EMPTY` - RX FIFO has no unread bytes (1).
  - `[3]`: `RX_FULL` - RX FIFO is full (1).
  - `[4]`: `OVERRUN` - RX overrun error occurred.
  - `[5]`: `FRAME_ERR` - Stop bit framing error occurred.
- **`BAUDDIV` (0x08)**:
  - `[15:0]`: `DIV` - Prescaler integer divisor. Reset default `0x0036` (54 for 100 MHz clock -> 115200 baud).
- **`CTRL` (0x0C)**:
  - `[0]`: `TX_EN` - Enable transmitter.
  - `[1]`: `RX_EN` - Enable receiver.

---

## 3. RISC-V Machine Timer (`0x8000_1000`)

### Register Summary
| Offset | Name          | Access | Reset Value   | Description |
|--------|---------------|--------|---------------|-------------|
| `0x00` | `MTIME_LO`    | RW     | `0x0000_0000` | Lower 32 bits of 64-bit real-time counter |
| `0x04` | `MTIME_HI`    | RW     | `0x0000_0000` | Upper 32 bits of 64-bit real-time counter |
| `0x08` | `MTIMECMP_LO` | RW     | `0xFFFF_FFFF` | Lower 32 bits of 64-bit compare register |
| `0x0C` | `MTIMECMP_HI` | RW     | `0xFFFF_FFFF` | Upper 32 bits of 64-bit compare register |
| `0x10` | `CTRL`        | RW     | `0x0000_0000` | Timer enable and interrupt control |
| `0x14` | `PRESCALE`    | RW     | `0x0000_0000` | Prescaler division ratio ($N+1$) |

### Bitfield Details
- **`CTRL` (0x10)**:
  - `[0]`: `EN` - Timer increment enable.
  - `[1]`: `IRQ_EN` - Timer interrupt enable. When enabled and `mtime >= mtimecmp`, asserts `timer_irq`.
- **Interrupt Assertion**:
  - The timer interrupt `irq` is asserted when `(mtime >= mtimecmp) & CTRL[1]`.

---

## 4. GPIO Controller (`0x8000_2000`)

### Register Summary
| Offset | Name       | Access | Reset Value   | Description |
|--------|------------|--------|---------------|-------------|
| `0x00` | `DATA_OUT` | RW     | `0x0000_0000` | Output drive value for pins configured as output |
| `0x04` | `DATA_IN`  | RO     | External pin  | Synchronized input values from pins |
| `0x08` | `DIR`      | RW     | `0x0000_0000` | Pin direction: 1 = output, 0 = input |
| `0x0C` | `IRQ_MASK` | RW     | `0x0000_0000` | Interrupt enable mask (1 = enabled) |
| `0x10` | `IRQ_EDGE` | RW     | `0x0000_0000` | Trigger condition: 1 = rising edge, 0 = active high level |
| `0x14` | `IRQ_STAT` | W1C    | `0x0000_0000` | Interrupt pending flags; write 1 to clear |

---

## 5. I2C Controller (`0x8000_3000`)

### Register Summary
| Offset | Name       | Access | Reset Value   | Description |
|--------|------------|--------|---------------|-------------|
| `0x00` | `PRER_LO`  | RW     | `0x0000_00FF` | Prescaler lower 8 bits ($F_{sys} / (5 \times F_{SCL}) - 1$) |
| `0x04` | `PRER_HI`  | RW     | `0x0000_00FF` | Prescaler upper 8 bits |
| `0x08` | `CTRL`     | RW     | `0x0000_0000` | Core enable and interrupt enable |
| `0x0C` | `DATA`     | RW     | `0x0000_0000` | Write: Transmit byte (`TXR`); Read: Received byte (`RXR`) |
| `0x10` | `CMD_STAT` | RW     | `0x0000_0000` | Write: Command register; Read: Status register |

### Command & Status Bitfield Details
- **Command Register (`CMD`, Write @ 0x10)**:
  - `[7]`: `STA` - Generate START or Repeated START condition.
  - `[6]`: `STO` - Generate STOP condition.
  - `[5]`: `RD`  - Read byte from slave.
  - `[4]`: `WR`  - Write byte to slave.
  - `[3]`: `ACK` - Send ACK (0) or NACK (1) during read.
  - `[0]`: `IACK`- Interrupt Acknowledge (clears interrupt flag).
- **Status Register (`STAT`, Read @ 0x10)**:
  - `[7]`: `RXACK` - 0 = Acknowledged by slave, 1 = No acknowledge (NACK).
  - `[6]`: `BUSY`  - 1 = I2C bus is busy.
  - `[1]`: `TIP`   - 1 = Transfer in progress.
  - `[0]`: `IF`    - 1 = Interrupt flag (transfer finished, pending acknowledgment).

---

## 6. FIR Filter Accelerator (`0x8000_4000`)

### Register Summary
| Offset | Name        | Access | Reset Value   | Description |
|--------|-------------|--------|---------------|-------------|
| `0x00` | `CTRL`      | RW     | `0x0000_0000` | Enable, Flush, and Interrupt control |
| `0x04` | `STATUS`    | RO     | `0x0000_0001` | Status register (IDLE=1) |
| `0x08` | `DATA_IN`   | WO     | -             | Write input sample $x[n]$ (Q1.15 signed) to trigger computation |
| `0x0C` | `DATA_OUT`  | RO     | `0x0000_0000` | Read latest filtered output $y[n]$ (Q1.15 signed) |
| `0x10` | `COEF_ADDR` | RW     | `0x0000_0000` | Address index for coefficient RAM (0 to 15) |
| `0x14` | `COEF_DATA` | RW     | `0x0000_0000` | Write/Read coefficient $h[k]$ (Q1.15 signed) |
| `0x18` | `SHIFT`     | RW     | `0x0000_000F` | Arithmetic right shift amount (default 15 for Q1.15) |
| `0x1C` | `TAPS`      | RO     | `0x0000_0010` | Number of taps implemented (16) |

### Bitfield Details
- **`CTRL` (0x00)**:
  - `[0]`: `EN` - Filter computation enable.
  - `[1]`: `FLUSH` - Self-clearing reset of internal delay line circular buffer.
  - `[2]`: `IRQ_EN` - Assert `fir_irq` when output sample is ready (`DONE=1`).
- **`STATUS` (0x04)**:
  - `[0]`: `IDLE` - 1 = Accelerator ready to accept a new sample.
  - `[1]`: `DONE` - 1 = Filter calculation completed for the current sample.
  - `[2]`: `BUSY` - 1 = Accelerator currently multiplying and accumulating taps.
  - `[3]`: `SAT`  - 1 = Sticky saturation flag indicating output clipped to `[-32768, 32767]`.

---

## 7. PWM Generator (`0x8000_5000`)

### Register Summary
| Offset | Name       | Access | Reset Value   | Description |
|--------|------------|--------|---------------|-------------|
| `0x00` | `CTRL`     | RW     | `0x0000_0000` | Enable, polarity, and interrupt configuration |
| `0x04` | `PERIOD`   | RW     | `0x0000_0000` | Period value (shadowed, loaded on cycle rollover) |
| `0x08` | `DUTY`     | RW     | `0x0000_0000` | Duty cycle threshold (shadowed, loaded on rollover) |
| `0x0C` | `PRESCALE` | RW     | `0x0000_0000` | Clock divider ratio ($N+1$) |
| `0x10` | `COUNT`    | RO     | `0x0000_0000` | Current active counter value |
| `0x14` | `STATUS`   | RO/W1C | `0x0000_0000` | Rollover interrupt status |

### Bitfield Details
- **`CTRL` (0x00)**:
  - `[0]`: `EN` - Counter enable.
  - `[1]`: `POL` - Polarity: 0 = active high (`count < duty`), 1 = active low (`count >= duty`).
  - `[2]`: `IRQ_EN` - Generate interrupt on period rollover.
  - `[3]`: `FORCE` - Force shadow register reload immediately without waiting for rollover.

