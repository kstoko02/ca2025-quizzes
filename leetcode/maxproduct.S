.text
.global maxProduct
.extern highest_bit

maxProduct:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    la   s2, mask
    la   s5, highest
    la   s6, indices
    la   s7, len_arr
    li   s3, 0
bitmask_loop:
    beq  s3, a1, sort   # if i == n -> compare
    li   t6, 0           # m = 0
    
    lw   a0, 4(sp)
    slli t0, s3, 2
    add  t1, a0, t0
    lw   t2, 0(t1)       # t2 = words[i] 
    li   s4, 0           # s4 = j = 0
char_loop:
    add  t3, t2, s4
    lbu  t4, 0(t3)
    li   t5, 1
    beqz t4, store_mask       # == '\0' 

    addi t4, t4, -97          # t4 = t4 - 'a'
    sll  t5, t5, t4           # 1 << (t4)
    or   t6, t6, t5           # m |= ...
    addi s4, s4, 1            # j++
    j    char_loop
store_mask:
    add  t1, s7, t0
    sw   s4, 0(t1)        # store len_arr[i]
    add  t1, s2, t0
    sw   t6, 0(t1)        # store mask[i]
    mv   a0, t6
    jal  ra, highest_bit
    add  t1, s5, t0
    sw   a0, 0(t1)        # store highest[i]   
    addi s3, s3, 1
    j    bitmask_loop

sort:    
    li   s3, 0         # i = 0
loop_i:
    beq  s3, a1, loop_end
    slli t2, s3, 2
    add  t4, s6, t2
    sw   s3, 0(t4)
    addi s3, s3, 1
    j    loop_i
loop_end:    
    li   s3, 0         # i = 0
    addi t0, a1, -1
    
out_loop:
    beq  s3, t0, compare_pairs
    
    addi t1, s3, 1   
in_loop:
    beq  t1, a1, next_loop
    slli t2, s3, 2
    add  t4, s6, t2
    lw   t5, 0(t4)        #indices[i]
    mv   s8, t4
    mv   s10, t5
    slli t2, t5, 2
    add  t4, s5, t2
    lw   t5, 0(t4)        #highest[indices[i]]
    slli t2, t1, 2
    add  t4, s6, t2    
    lw   t6, 0(t4)        #indices[j]
    mv   s9, t4
    mv   s11, t6
    slli t2, t6, 2
    add  t4, s5, t2
    lw   t6, 0(t4)        #highest[indices[j]]
    bge  t5, t6, skip_swap
    sw   s11, 0(s8)
    sw   s10, 0(s9)
    
skip_swap:
    addi t1, t1, 1
    j    in_loop
next_loop:
    addi s3, s3, 1
    j    out_loop
    
compare_pairs:
    li   s4, 0          # i = 0
    li   s3, 0          # s3 = ans
outer_loop:
    bge  s4, a1, done
    
    slli t2, s4, 2
    add  t4, s6, t2
    lw   s10, 0(t4)         # idx1
    addi t1, s4, 1      # j = i + 1
inner_loop:
    bge  t1, a1, next_i
    
    slli t2, t1, 2
    add  t4, s6, t2
    lw   s11, 0(t4)         # idx2
    
    slli t2, s10, 2
    add  t4, s7, t2
    lw   t5, 0(t4)         # len_arr[idx1]
    
    slli t2, s11, 2
    add  t4, s7, t2
    lw   t6, 0(t4)         # len_arr[idx2]
    
#    mul  s0, t5, t6    #prod
    li   s0, 0
    li   t3, 0
mul_loop:
    beq t3, t6, mul_end
    add s0, s0, t5
   addi t3, t3, 1
    j    mul_loop
mul_end:
    bge  s3, s0, skip_pair
    
    slli t2, s10, 2
    add  t4, s2, t2
    lw   t5, 0(t4)      # mask[idx1]

    slli t2, s11, 2
    add  t4, s2, t2
    lw   t6, 0(t4)      # mask[idx2]

    and  t2, t5, t6
    bnez t2, skip_pair   # mask[i] & mask[j] == 0
    
    bge  s3, s0, skip_pair
    mv   s3, s0
skip_pair:
    addi t1, t1, 1
    j    inner_loop
next_i:
    addi s4, s4, 1
    j    outer_loop
done:
    mv   a0, s3      # a0 = ans
    lw   ra, 0(sp)
    addi sp, sp, 8  
    jr   ra
.size maxProduct, .-maxProduct
