.data
BF16_SIGN_MASK: .half 0x8000
BF16_EXP_MASK:  .half 0x7F80
BF16_MANT_MASK: .half 0x007F
BF16_EXP_BIAS: .word 127
.text
.globl main
main:
#    li    a0, 0x3E00
#    li    a1, 0x42F6
#    jal   ra, bf16_sqrt
#    li    a7, 1
#    ecall
#    li    a7, 10    #exit
#    ecall


BF16_NAN:
    li    t1, 0x7FC0
    mv    a0, t1
    jr    ra

BF16_ZERO:
    li    t1, 0x0000
    mv    a0, t1
    jr    ra    
        
bf16_isnan:
    la    t0, BF16_EXP_MASK
    lh    t1, 0(t0)
    la    t0, BF16_MANT_MASK
    lh    t2, 0(t0)
    and   t3, a0, t1
    bne   t3, t1, not_nan
    and   t4, a0, t2
    beqz  t4, not_nan
    li    a0, 1
    jr    ra
not_nan:
    li    a0, 0
    jr    ra    

bf16_isinf:
    la    t0, BF16_EXP_MASK
    lh    t1, 0(t0)
    la    t0, BF16_MANT_MASK
    lh    t2, 0(t0)
    and   t3, a0, t1
    bne   t3, t1, not_inf
    and   t4, a0, t2
    bnez  t4, not_inf
    li    a0, 1
    jr    ra
not_inf:
    li    a0, 0
    jr    ra    
    
bf16_iszero:
    li    t1, 0x7FFF
    and   t2, a0, t1
    seqz  a0, t2
    jr    ra

f32_to_bf16:
    li    t1, 0xFF
    srli  t2, a0, 23
    and   t3, t1, t2
    beq   t1, t3, re_bf16
    li    t1, 0x7FFF
    srli  t2, a0, 16
    andi  t3, t2, 1
    add   t4, t3, t1
    add   a0, a0, t4
    srli  a0, a0, 16
    jr    ra
re_bf16:
    li    t1, 0xFFFF
    srli  t2, a0, 16
    and   a0, t1, t2
    jr    ra

bf16_to_f32:
    slli  t1, a0, 16
    mv    a0, t1
    jr    ra

set_value:
    srli  t1, a0, 15
    andi  s0, t1, 1    #sign_a
    srli  t1, a1, 15
    andi  s1, t1, 1    #sign_b
    
    li    t1, 0x7F
    and   s4, a0, t1    #mant_a
    and   s5, a1, t1    #mant_b    
    
    li    t1, 0xFF
    srai  t2, a0, 7
    and   s2, t2, t1    #exp_a
    srai  t2, a1, 7
    and   s3, t2, t1    #exp_b
    jr    ra
    
 bf16_add:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, set_value
    lw    ra, 0(sp)
    addi  sp, sp, 4
    
    li    t1, 0xFF
    li    t2, 1
    bne   s2, t1, skip_expa
    beq   s4, t2, re_a
    bne   s3, t1, re_a
    beq   s5, t2, re_b
    beq   s0, s1, re_b
    j     BF16_NAN
skip_expa:
    beq   s3, t1, re_b
    bnez  s2, skipA
    bnez  s4, skipA
    j     re_b
skipA:
    bnez  s3, skipB
    bnez  s5, skipB
    j     re_a    
skipB:
    li    t2, 0x80
    beqz  s2, skipC
    or    s4, s4, t2
skipC:
    beqz  s3, skipD
    or    s5, s5, t2
skipD:
    sub   s6, s2, s3    #exp_diff
    
    blez  s6, diff_zero
    mv    s8, s2
    li    t3, 8
    bgt   s6, t3, re_a
    srl   s5, s5, s6
    j     skip_diff
diff_zero:
    bnez  s6, diff_neg
    mv    s8, s2
    j     skip_diff
diff_neg:
    mv    s8, s3
    li    t3, -8
    blt   s8, t3, re_b
    sub   t4, x0, s6
    srl   s4, s4, t4

skip_diff:
    # sign_a == sign_b
    bne   s0, s1, sign_neq
    mv    s7, s0
    add   s9, s4, s5
    li    t3, 0x100
    and   t4, s9, t3
    beqz  t4, skip_sign
    srli  s9, s9, 1
    addi  s8, s8, 1
    blt   s8, t1, skip_sign
    j     re_bits
sign_neq:
    blt    s4, s5, mant_lt
    mv     s7, s0
    sub    s9, s4, s5
    j      re_mant
mant_lt:
    mv    s7, s1
    sub   s9, s5, s4    
re_mant:
    beqz  s9, BF16_ZERO
loopA:
    and   t3, s9, t2
    bnez  t3, skip_sign
    slli  s9, s9,1
    addi  s8, s8, -1
    blez  s8, BF16_ZERO
    j     loopA
skip_sign:
    slli  t3, s7, 15
    and   t4, s8, t1
    slli  t4, t4, 7
    li    t5, 0x7F
    and   t6, s9, t5
    or    a0, t3, t4
    or    a0, a0, t6
    jr    ra
    
re_a:
    jr    ra 

re_b:
    mv    a0, a1
    jr    ra    
    
bf16_sub:
    la    t0, BF16_SIGN_MASK
    lhu   t1, 0(t0)
    xor   a1, a1, t1
    j     bf16_add
    
bf16_mul:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, set_value
    lw    ra, 0(sp)
    
    xor   s7, s0, s1    #result_sign
    li    t1, 0xFF
    bne   s2, t1, skip_a
    bnez  s4, re_a
    bnez  s3, re_bits
    bnez  s5, re_bits
    j     BF16_NAN
skip_a:
    bne   s3, t1, skip_b
    bnez  s5, re_b
    bnez  s2, re_bits
    bnez  s4, re_bits
    j     BF16_NAN
re_bits:
    li    t3, 0x7F80
    slli  t4, s7, 15
    or    a0, t4, t3
    jr    ra

re_bits2:
    slli  a0, s7, 15
    jr    ra    
    
skip_b:
    bnez  s2, skip_zero
    beqz  s4, re_bits2
    bnez  s3, skip_zero
    beqz  s5, re_bits2
skip_zero:    
    li    s10, 0    #exp_adjust
    li    t2, 0x80
    
    bnez  s2, skipE
    li    s2, 1
loopB:
    and   t3, s4, t2
    bnez  t3, skipF
    slli  s4, s4, 1
    addi  s10, s10, -1
    j    loopB
skipE:
    or    s4, s4, t2
skipF:    
    bnez  s3, skipG
    li    s3, 1
loopC:
    and   t3, s5, t2
    bnez  t3, skip_exp
    slli  s5, s5, 1
    addi  s10, s10, -1
    j    loopC        
skipG:
    or    s5, s5, t2
skip_exp:
    mv    a0, s4
    mv    a1, s5
    sw    ra, 0(sp)
    jal   ra, prod
    mv    s9, a0        #result_mant
    lw    ra, 0(sp)
    addi  sp, sp, 4
    la    t0, BF16_EXP_BIAS
    lw    t3, 0(t0)
    add   s8, s2, s3
    add   s8, s8, s10
    sub   s8, s8, t3    #result_exp
    
    li    t3, 0x8000
    and   t4, s9, t3
    li    t5, 0x7F
    beqz  t4, skipH
    addi  s8, s8, 1
    srli  s9, s9, 8
    and   s9, s9, t5
    j     skip_mant
skipH:
    srli  s9, s9, 7
    and   s9, s9, t5
skip_mant:
    bge   s8, t1, re_bits
    blt   x0, s8, skipJ
    li    t3, -6
    bge   s8, t3, skipI
    j     re_bits2
skipI:
    li    t3, 1
    sub   t4, t3, s8
    srl   s9, s9, t4
    mv    s8, x0
skipJ:
    slli  t3, s7, 15
    and   t4, s8, t1
    slli  t4, t4, 7
    and   t6, s9, t5
    or    a0, t3, t4
    or    a0, a0, t6
    jr    ra
    
bf16_div:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, set_value
    lw    ra, 0(sp)
    addi  sp, sp, 4        
    
    xor   s7, s0, s1    #result_sign
    li    t1, 0xFF
    li    t2, 0x80
    li    t5, 0x7F
    
    bne   s3, t1, skipK
    bnez  s5, re_b
    bne   s2, t1, re_bits2
    bnez  s4, re_bits2
    j     BF16_NAN
skipK:
    bnez  s3, skipL
    bnez  s5, skipL
    bnez  s2, re_bits
    bnez  s4, re_bits
    j     BF16_NAN
skipL:
    bne   s2, t1, skipM
    bnez  s4, re_a
    j     re_bits
skipM:
    bnez  s2, skipN
    bnez  s4, skipN
    j     re_bits2
skipN:
    beqz  s2, skipO
    or    s4, s4, t2
skipO:
    beqz  s3, skipP
    or    s5, s5, t2    
skipP:    
    slli  s11, s4, 15    #dividend
    mv    s6, s5         #divisor
    li    s9, 0          #quotient
    
    li    t3, -1
    li    t4, 16
    li    t2, 15
loopD:
    addi  t3, t3, 1
    bge   t3, t4, skipQ     
    slli  s9, s9, 1
    sub   t6, t2, t3
    sll   t6, s6, t6
    blt   s11, t6, loopD
    sub   s11, s11, t6
    ori   s9, s9, 1
    j     loopD
skipQ:
    la    t0, BF16_EXP_BIAS
    lw    t2, 0(t0)
    sub   s8, s2, s3
    add   s8, s8, t2      #result_exp
    
    bnez  s2, skipR
    addi  s8, s8, -1    
skipR:
    bnez  s3, skipS
    addi  s8, s8, 1
skipS:
    li    t2, 0x8000
    li    t4, 1    
    and   t3, s9, t2
    beqz  t3, loopE
    srli  s9, s9, 8
    j     skip_quo   
loopE:
    bnez  t3, skipT
    ble   s8, t4, skipT
    slli  s9, s9, 1
    addi  s8, s8, -1
    j    loopE
skipT:
    srli  s9, s9, 8    
skip_quo:
    and   s9, s9, t5
    
    bge   s8, t1, re_bits
    ble   s8, x0, re_bits2
    slli  t3, s7, 15
    and   t4, s8, t1
    slli  t4, t4, 7
    and   t6, s9, t5
    or    a0, t3, t4
    or    a0, a0, t6
    jr    ra
    

bf16_sqrt:
    li    t1, 0xFF
    li    t2, 0x80
    li    t5, 0x7F
    srli  t3, a0, 15
    andi  s0, t3, 1     #sign
    srli  t3, a0, 7
    and   s1, t3, t1    #exp
    and   s2, a0, t5    #mant
    
    bne   s1, t1, skip_exp2
    bnez  s2, re_a
    bnez  s0, BF16_NAN
    j     re_a
skip_exp2:    
    bnez  s1, skip_zero2
    bnez  s2, skip_zero2
    j     BF16_ZERO
skip_zero2:    
    bnez  s0, BF16_NAN
    beqz  s1, BF16_ZERO
    
    la    t0, BF16_EXP_BIAS
    lw    t3, 0(t0)
    sub   s3, s1, t3    #e
    or    s5, t2, s2    #m
    
    andi   t4, s3, 1
    beqz   t4, skipU
    slli   s5, s5, 1
    addi   t4, s3, -1
    srai   t4, t4, 1
    add    s4, t4, t3    #new_exp
    j      skip_e
skipU:    
    srai   t4, s3, 1
    add    s4, t4, t3    #new_exp
skip_e:    
    li     s6, 90        #low
    li     s7, 256       #high
    li     s8, 128       #result
    addi   sp, sp, -4
    sw     ra, 0(sp)
    
loopF:
    blt    s7, s6, skip_loopF
    add    t3, s6, s7
    srli   s10, t3, 1    #mid
    mv     a0, s10
    mv     a1, s10
    jal    ra, prod 
    srli   s11, a0, 7       #sq
        
    blt    s5, s11, skipV
    mv     s8, s10
    addi   s6, s10, 1
    j      loopF
skipV:
    addi   s7, s10, -1
    j      loopF
skip_loopF:
    lw     ra, 0(sp)
    addi   sp, sp, 4
    li     t2, 256    
    blt    s8, t2, skip_256
    srli   s8, s8, 1
    addi   s4, s4, 1
    j      skip_result
skip_256:
    bge    s8, t6, skip_result
    li     t3, 1
loopG:
    bge    s8, t6, skip_result
    bge    t3, s4, skip_result
    slli   s8, s8, 1
    addi   s4, s4, -1
    j      loopG
skip_result:     
    and    s9, s8, t5    #new_mant
    
    blt    s4, t1, skip_inf
    li     t3, 0x7F80
    mv     a0, t3
    jr     ra
skip_inf:    
    bge    x0, s4, BF16_ZERO
    and    t3, s4, t1
    slli   t3, t3, 7
    or     a0, t3, s9
    jr     ra      
    
prod:
    li     t3, 0
loop_mul:
    beqz   a1, skip_mul
    andi   t4, a1, 1
    beqz   t4, next_mul
    add    t3, t3, a0
next_mul:
    slli   a0, a0, 1
    srli   a1, a1, 1
    bnez   a1, loop_mul
skip_mul:
    mv     a0, t3
    jr     ra    