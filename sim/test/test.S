# Minimal RV32IM test for CV32E40S
# Boot at 0x80000000, tohost at 0x80001000

    .section .text.start, "ax"
    .globl _start
_start:
    # Simple ALU tests
    li   x1, 100
    li   x2, 200
    add  x3, x1, x2     # x3 = 300
    sub  x4, x2, x1     # x4 = 100
    xor  x5, x1, x2     # x5 = 100^200
    or   x6, x1, x2     # x6 = 100|200
    and  x7, x1, x2     # x7 = 100&200
    sll  x8, x1, x1     # shift left
    srl  x9, x2, x1     # shift right

    # M-extension tests
    mul  x10, x1, x2    # x10 = 100*200 = 20000
    div  x11, x2, x1    # x11 = 200/100 = 2
    rem  x12, x2, x1    # x12 = 200%100 = 0

    # Branch test
    li   x13, 2
    bne  x11, x13, fail # x11 should be 2

pass:
    li   x14, 0x80001000
    li   x15, 1
    sw   x15, 0(x14)    # write 1 to tohost => PASS
    j    pass            # loop (should $finish before here)

fail:
    li   x14, 0x80001000
    li   x15, 2
    sw   x15, 0(x14)    # write non-1 to tohost => FAIL
    j    fail
