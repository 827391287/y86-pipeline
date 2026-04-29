OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS {
    . = 0x00000000;
    .text : { *(.text.init) *(.text*) }
    .rodata : { *(.rodata*) }
    . = ALIGN(4);
    .data : { *(.data*) *(.sdata*) }
    .bss  : { *(.bss*)  *(.sbss*)  }
}
