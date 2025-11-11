    .text
    .global  hanoi
    
    .extern hanoi_buf
hanoi:
    # Gray code formula: gray(n) = n XOR (n >> k)
    addi sp, sp,-12
    sw x9, 0(sp)
    sw x18, 4(sp)
    sw x19, 8(sp)
    la      x29, hanoi_buf
    srli    x5, x10, 1
    xor     x6, x10, x5
    addi    x7, x10, -1
    srli    x28, x7, 1
    xor     x7, x7, x28
    xor     x5, x6, x7
    addi    x9, x0, 0
    andi    x6, x5, 1
    bne     x6, x0, disk_found
    addi    x9, x0, 1
    andi    x6, x5, 2
    bne     x6, x0, disk_found
    addi    x9, x0, 2
disk_found:
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match
    jal     x0, continue_move
pattern_match:
continue_move:
    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x29, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large

    addi    x19, x18, 2

    addi    x6, x0, 3
    blt     x19, x6, display_move
    sub     x19, x19, x6
    jal     x0, display_move

handle_large:
    lw      x6, 20(x29)

    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move:
    sw     x9, 0(x11)
    sw     x18, 0(x12)
    sw     x19, 0(x13)
    
    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x29, x5

    sw      x19, 0(x5)
    
    lw x9, 0(sp)
    lw x18, 4(sp)
    lw x19, 8(sp)
    addi sp, sp, 12
    ret
