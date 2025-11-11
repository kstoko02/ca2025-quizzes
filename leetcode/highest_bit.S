.text
.global highest_bit

highest_bit:
    bnez  a0, clz
    li    a0, -1
    jr    ra
clz:    
    li    t4, 32       # n = 32
    li    t5, 16       # c = 16
    mv    t2, a0       # t2 = x

clz_loop:
    srl    t3, t2, t5      # y = x >> c
    beqz   t3, skip       # if y == 0, skip
    sub    t4, t4, t5      # n -= c
    mv     t2, t3           # x = y

skip:
    srli    t5, t5, 1      # c >>= 1
    bnez    t5, clz_loop   # while (c != 0)

    sub     a0, t4, t2      # n - x
    li      t6, 31
    sub     a0, t6, a0      # return 31 - clz(x)
    jr      ra
.size highest_bit, .-highest_bit
