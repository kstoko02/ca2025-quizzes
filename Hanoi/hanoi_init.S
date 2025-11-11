    .text
    .global  hanoi_init
    
    .extern hanoi_buf
hanoi_init:
    la      x29, hanoi_buf
    sw      x8, 0(x29)
    sw      x9, 4(x29)
    sw      x18, 8(x29)
    sw      x19, 12(x29)
    sw      x20, 16(x29)

    li      x5, 0x15
    la      x29, hanoi_buf
    sw      x5, 20(x29)
    sw      x5, 24(x29)
    sw      x5, 28(x29)

    sw      x0, 20(x29)
    sw      x0, 24(x29)
    sw      x0, 28(x29)
    ret
