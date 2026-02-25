OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 256K
}

SECTIONS
{
    .text : {
        *(.text.start)
        *(.text*)
    } > RAM

    .data : ALIGN(4) {
        *(.data*)
        *(.rodata*)
    } > RAM

    .bss : ALIGN(4) {
        *(.bss*)
        *(COMMON)
    } > RAM

    /* tohost symbol at fixed address */
    .tohost 0x80001000 (NOLOAD) : {
        *(.tohost)
    }
}
