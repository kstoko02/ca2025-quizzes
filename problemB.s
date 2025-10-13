.data    
str1: .string "failed"
str2: .string "passed"
.text
.globl main
main:
    li      s0, 0        # fl = 0
    li      t1, 255        # max fl
    li      s4, -1         # previous_value
test_loop:
    mv      a0, s0
    jal     ra, uf8_decode
    mv      s5, a0          # value

    jal     ra, uf8_encode_fast
    mv      t4, a0          # fl2

    bne     t4, s0, fail
    bge     s4, s5, fail
    mv      s4, s5
    addi    s0, s0, 1
    ble     s0, t1, test_loop    # if(t0 <= t1) test_loop

    la    a0, str2
    li    a7, 4
    ecall  
    j    end

fail:
    mv      a0, s0       
    li      a7,1
    ecall
    j       end

end:
    li    a7,10    #exit
    ecall                   

# clz start
clz:
    li    t4, 32       # n = 32
    li    t1, 16       # c = 16
    mv    t2, a0       # t2 = x

clz_loop:
    srl    t3, t2, t1      # y = x >> c
    beqz   t3, skip       # if y == 0, skip
    sub    t4, t4, t1      # n -= c
    mv     t2, t3           # x = y

skip:
    srli    t1, t1, 1      # c >>= 1
    bnez    t1, clz_loop   # while (c != 0)

    sub     a0, t4, t2      # return n - x
    jr      ra
#clz end

uf8_decode:
    andi    t4, a0, 0x0F
    srli    t1, a0, 4        # t1 = exponent
    li      t2, 0x7FFF
    li      t3, 15
    sub     t3, t3, t1       # t3 = 15 - exponent
    srl     t2, t2, t3
    slli    t2, t2, 4
    sll     t4, t4, t1
    add     a0, t4, t2
    jr      ra

uf8_encode_fast:
    li      t1, 16
    blt     a0, t1, small_val    # value < 16
    mv      s3, a0
    addi    sp, sp, -4
    sw      ra, 0(sp)

    jal     ra, clz
    mv      t1, a0            # lz = clz(value)
    li      t2, 31
    sub     t3, t2, t1       # msb = 31 - clz(value)

    li      t4, 0
    li      t5, 0
    
    li      t6, 5
    blt     t3, t6, compute_overflow
    addi    t4, t3, -4        # exponent = msb - 4
    li      t6, 16
    bge     t4, t6, set_15_exp
compress:
    li      t6, 0
loopA:
    bge     t6, t4, loopB
    slli    t5, t5, 1
    addi    t5, t5, 16
    addi    t6, t6, 1
    j    loopA
loopB:
    blez    t4, compute_overflow
    bge     t1, t5, compute_overflow
    addi    t5, t5, -16
    srli    t5, t5, 1
    addi    t4, t4, -1
    j    loopB         

compute_overflow:    
    li      t6, 16
    bge     t4, t6, end_compute
    slli    s1, t5, 1
    addi    s1, s1, 16
    blt     t1, s1, end_compute  
    mv      t5, s1
    addi    t4, t4, 1
    j       compute_overflow
end_compute:
    sub     s2, s3, t5
    srl     s2, s2, t4
    slli    t4, t4, 4
    or      a0, t4, s2
    lw      ra, 0(sp)
    addi    sp, sp, 4
    jr      ra

set_15_exp:
    li      t4, 15
    j       compress
    
small_val:
    mv      a0, a0
    jr        ra


    