OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  /* Must cover fixed .text/.data.random* placement. Keep in sync with your TB SRAM size. */
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 1M
}

SECTIONS
{
  . = ORIGIN(RAM);

  .text.init : { *(.text.init) } > RAM

  /* Keep _fuzz_main at a stable absolute address (matches RV64 templates and Spike dep-tracking range). */
  .text.fuzz_main 0x80000480 : { *(.text.fuzz_main) } > RAM

  /* Fixed HTIF locations (compatible with simple TB + Spike). */
  .tohost 0x80001000 : { *(.tohost) } > RAM

  .text : { *(.text) *(.text.*) } > RAM
  .rodata : ALIGN(4) { *(.rodata*) } > RAM

  /* Place random blocks at fixed offsets (same idea as the RV64 templates).
   * These must appear before .data so they don't get swallowed by a broad .data* match.
   */
  .data.random0 0x80010000 : { *(.data.random0) } > RAM
  .data.random1 0x80020000 : { *(.data.random1) } > RAM
  .data.random2 0x80030000 : { *(.data.random2) } > RAM
  .data.random3 0x80040000 : { *(.data.random3) } > RAM
  .data.random4 0x80050000 : { *(.data.random4) } > RAM
  .data.random5 0x80060000 : { *(.data.random5) } > RAM

  /* Keep .data narrow to avoid capturing .data.random* (those are placed above). */
  .data : ALIGN(4) { *(.data) } > RAM
  .bss  : ALIGN(4) { *(.bss*) *(COMMON) } > RAM
}
