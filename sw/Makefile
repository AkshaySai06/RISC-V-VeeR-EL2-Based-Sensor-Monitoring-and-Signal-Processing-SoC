# SPDX-License-Identifier: Apache-2.0
# Firmware Makefile for VeeR EL2 SoC per Section 13.2 of Spec v2.0

CROSS_COMPILE ?= /home/student/tools/xpack-riscv-none-elf-gcc-14.3.0-1/bin/riscv-none-elf-
CC            = $(CROSS_COMPILE)gcc
OBJCOPY       = $(CROSS_COMPILE)objcopy
OBJDUMP       = $(CROSS_COMPILE)objdump

CFLAGS  = -O2 -march=rv32imc_zicsr_zifencei -mabi=ilp32 -nostdlib -ffreestanding -Wall -I.
LDFLAGS = -T link.ld -nostdlib -Wl,--build-id=none

SRCS_C = main.c uart.c i2c.c fir.c pwm.c timer.c gpio.c
SRCS_S = crt0.S

OBJS = $(SRCS_S:.S=.o) $(SRCS_C:.c=.o)

all: main.elf main.bin main.dis main.hex

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

main.elf: $(OBJS) link.ld
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

main.bin: main.elf
	$(OBJCOPY) -O binary $< $@

main.dis: main.elf
	$(OBJDUMP) -d $< > $@

# Generate 32-bit little-endian hex words (padded to 8192 words / 32 KB) for Verilog $readmemh
main.hex: main.bin
	python3 -c "data = open('main.bin', 'rb').read(); rem = len(data)%4; data += b'\x00'*(4-rem) if rem else b''; words = [int.from_bytes(data[i:i+4], 'little') for i in range(0, len(data), 4)]; [print(f'{w:08x}') for w in words]; [print('00000000') for _ in range(8192 - len(words))]" > $@

clean:
	rm -f *.o *.elf *.bin *.hex *.dis

.PHONY: all clean

