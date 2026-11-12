/* SPDX-License-Identifier: Apache-2.0 */
/* Linker script for VeeR EL2 SoC per Section 4.2 of Spec v2.0 */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  imem (rx) : ORIGIN = 0x00000000, LENGTH = 32K
  dmem (rw) : ORIGIN = 0x10000000, LENGTH = 32K
}

SECTIONS {
  .text : {
    . = ALIGN(4);
    *(.text.init)
    *(.text)
    *(.text.*)
    . = ALIGN(4);
  } > imem

  .rodata : {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata.*)
    *(.srodata)
    *(.srodata.*)
    . = ALIGN(4);
    _sidata = LOADADDR(.data);
  } > imem

  .data : {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data.*)
    *(.sdata)
    *(.sdata.*)
    . = ALIGN(4);
    PROVIDE( __global_pointer$ = . + 0x800 );
    _edata = .;
  } > dmem AT > imem

  .bss : {
    . = ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > dmem

  . = ALIGN(16);
  _end = .;
  __stack_top = ORIGIN(dmem) + LENGTH(dmem) - 16;

  /DISCARD/ : {
    *(.note.gnu.build-id)
    *(.comment)
    *(.eh_frame)
  }
}

