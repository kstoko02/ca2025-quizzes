.data
#############################
# test1
#############################
abcdefghij:  .string "abcdefghij"
klmnopqrst:  .string "klmnopqrst"
uvwxyzabcd:  .string "uvwxyzabcd"
mnopqrstu:  .string "mnopqrstu"
ghijklmno:  .string "ghijklmno"
qrstuvwxy:  .string "qrstuvwxy"
abcdefklmn:  .string "abcdefklmn"

test1: .word abcdefghij, klmnopqrst, uvwxyzabcd, mnopqrstu, ghijklmno, qrstuvwxy, abcdefklmn
n1:    .word 7

##############################
# test2
##############################
abcdefg:    .string "abcdefg"
hijklmnop:   .string "hijklmnop"
qrstuv:  .string "qrstuv"
wxyz:    .string "wxyz"
ijk:   .string "ijk"
mnopqr:  .string "mnopqr"

test2:   .word abcdefg, hijklmnop, qrstuv, wxyz, ijk, mnopqr
n2:      .word 6

##############################
# test3
##############################
abcdefgh:     .string "abcdefgh"
ijklmnop:    .string "ijklmnop"
qrstuvwx:   .string "qrstuvwx"
yz:  .string "yz"
mnop: .string "mnop"
test3: .word abcdefgh, ijklmnop,qrstuvwx, yz, mnop
n3:    .word 5

mask:    .zero 28   
highest: .zero 28
indices: .zero 28
len_arr: .zero 28
newline: .string "\n"
ans:     .word 0

.text
.globl main
main:
    la   a0, test1       # a0 = test1[]
    lw   a1, n1          # a1 = n1 = 6
    jal  ra, maxProduct
    jal  ra, clear
    
    la   a0, test2       # a0 = test2[]
    lw   a1, n2          # a1 = n2 = 7
    jal  ra, maxProduct
    jal  ra, clear

    la   a0, test3       # a0 = test3[]
    lw   a1, n3          # a1 = n3 = 4
    jal  ra, maxProduct

    li   a7, 10
    ecall

maxProduct:
    la   s2, mask
    li   s3, 0
bitmask_loop:
    beq  s3, a1, compare_pairs   # if i == n -> compare
    li   t6, 0           # m = 0
    
    slli t0, s3, 2
    add  t1, a0, t0
    lw   t2, 0(t1)       # t2 = words[i] 
    li   s4, 0           # s4 = j = 0
char_loop:
    add  t3, t2, s4
    lbu  t4, 0(t3)
    beqz t4, store_mask       # == '\0' 

    addi t4, t4, -97          # t4 = t4 - 'a'
    li   t5, 1
    sll  t5, t5, t4           # 1 << (t4)
    or   t6, t6, t5           # m |= ...
    addi s4, s4, 1            # j++
    j    char_loop
store_mask:
    add  t1, s2, t0
    sw   t6, 0(t1)
    addi s3, s3, 1
    j    bitmask_loop

compare_pairs:
    li   s4, 0          # i = 0
    la   s3, ans        # s3 = ans
    addi sp, sp, -8
    sw   ra, 0(sp)
outer_loop:
    bge  s4, a1, done

    addi t1, s4, 1      # j = i + 1
inner_loop:
    bge  t1, a1, next_i

    slli t2, s4, 2
    add  t4, s2, t2
    lw   t5, 0(t4)      # mask[i]

    slli t2, t1, 2
    add  t4, s2, t2
    lw   t6, 0(t4)      # mask[j]

    and  t2, t5, t6
    bnez t2, skip_pair   # mask[i] & mask[j] == 0
    
    mv   s0, a0
    slli t2, s4, 2
    add  t4, s0, t2
    lw   a0, 0(t4)         # word[i]
    jal  ra, strlen
    mv   t5, a0            # len1

    slli t2, t1, 2
    add  t4, s0, t2
    lw   a0, 0(t4)         # word[j]
    jal  ra, strlen
    mv   t6, a0            # len2
    mv   a0, s0

    mul  t2, t5, t6
    lw   t3, 0(s3)
    bge  t3, t2, skip_pair
    sw   t2, 0(s3)
skip_pair:
    addi t1, t1, 1
    j    inner_loop
next_i:
    addi s4, s4, 1
    j    outer_loop
done:
    lw   a0, 0(s3)      # a0 = ans
    li   a7, 1
    ecall
    la   a0, newline
    li   a7, 4
    ecall
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra
    
strlen:
    mv   t0, a0
    li   t3, 0
strlen_loop:
    lbu  t2, 0(t0)
    beqz t2, strlen_end
    addi t3, t3, 1
    addi t0, t0, 1
    j    strlen_loop
strlen_end:
    mv   a0, t3
    jr   ra

    
clear:
    la   t0, ans
    sw   x0, 0(t0)        # clear ans
    la   t0, mask
    li   t1, 7
    li   t2, 0
clear_loop:
    beqz t1, clear_end
    sw   t2, 0(t0)        # clear mask
    addi t0, t0, 4
    addi t1, t1, -1
    j    clear_loop 
clear_end:    
    jr   ra