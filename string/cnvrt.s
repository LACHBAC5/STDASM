.section .data
.section .bss
.section .text
.extern _start
# to string conversions
.globl itos
.globl uitos
.globl dtos
# from string conversions
.globl stoi
.globl stoui
.globl stod


# function "itos"
# DESCRIPTION
# Convert an integer to a string
# INPUT:
# %rax=number
# %rbx=buffer
# OUTPUT
# %rax=chars written
# REGS
# changes %rax
# needs 2 FPU slots
itos:
    # check sign
    cmpq $0, %rax               # compare to 0
    jg 1f                       # if it is higher skip to 1
    movb $45, (%rbx)            # load '-' at m8 %rbx 
    inc %rbx                    # inc pointer %rbx
    neg %rax                    # negate x so it is positive
    1:
uitos:
    # save regs
    pushq %rbx
    pushq %rdx
    pushq %r8
    # save 8 bytes from stack
    subq $8, %rsp

    movq %rax, (%rsp)           # save x to memory for the FPU
    # calculate number of base10 digits
    fld1                        # load 1
    fildl (%rsp)                # load x from memory
    fyl2x                       # 1*log2(x)+pop
    fldlg2                      # load log10(2)
    fmulp %st(0), %st(1)        # log10(2)*log2(x)=log10(x)
    fisttpl (%rsp)              # truncate+pop
    addq (%rsp), %rbx           # add result to pointer
    
    # convert number starting from least significant
    # saving into rightmost string place
    movq $10, %r8               # save divisor
    1:
    xorq %rdx, %rdx             # clear %rdx <- div %rdx:%rax
    div %r8                     # divide %rax by 10, remainer->%rdx, base->%rax
    addq $48, %rdx              # convert scalar to ascii digit
    movb %dl, (%rbx)            # save ascii digit in str
    dec %rbx                    # save from right to left
    cmpq $0, %rax               # until %rax is 0
    ja 1b

    # gen output -> (chars added)-1
    movq (%rsp), %rax
    inc %rax

    # return 8 bytes to the stack
    addq $8, %rsp
    # restore regs
    popq %r8
    popq %rdx
    popq %rbx
    ret

# function "dtos"
# DESCRIPTION
# Convert a double to a string
# INPUT
# %rax=double
# %rbx=buffer
# OUTPUT
# %rax=chars written
# REGS
# changes %xmm0, %xmm1, %xmm2
# changes %rax
# calls itos
dtos:
    # save regs
    pushq %rbx
    pushq %r8
    # save 8 bytes from stack
    subq $8, %rsp

    #           unwind loop to extract initial integer part
    movq %rax, %xmm0            # load double floating-point
    roundsd $3, %xmm0, %xmm1    # copy and truncate value
    subsd %xmm1, %xmm0          # sub truncated and floating-point values
    cvtsd2si %xmm1, %rax        # copy truncated value in gp reg
    #       check sign
    cmpq $0, %rax               # cmp integer part with 0
    jg 1f                       # negate if below
    movl $0, (%rsp)             # save (32)0 at low
    movl $2147483648, 4(%rsp)   # save 1,(31)0 at high
    movq (%rsp), %xmm1          # move result into xmm reg
    xorpd %xmm1, %xmm0          # xor removes sign
    1:
    call itos                   # convert gp reg into string
    addq %rax, %rbx             # offset pointer to free memory

    #           add '.' to buffer
    movb $46, (%rbx)
    inc %rbx

    movq $10, %rax              # save 10 numbers after the floating point
    cvtsi2sd %rax, %xmm2        # set scalar to 10 
    1:
    mulsd %xmm2, %xmm0          # multiply float by 10
    roundsd $3, %xmm0, %xmm1    # copy and truncate value
    subsd %xmm1, %xmm0          # sub truncated and floating-point values
    cvtsd2si %xmm1, %r8         # copy truncated value in gp reg
    addq $48, %r8               # convert gp reg to ascii digit
    movb %r8b, (%rbx)           # write digit to buffer

    inc %rbx
    dec %rax
    cmpq $0, %rax
    ja 1b

    # return 8 bytes to stack
    addq $8, %rsp
    #           calculate length + restore regs
    popq %r8
    movq %rbx, %rax             # copy pointer to last char
    popq %rbx                   # restore caller reg/pointer to buffer
    subq %rbx, %rax             # sub last ptr from first ptr
    ret


# FUCNTION "stoi"
# DESCRIPTION
# Converts a string to an integer
# INPUT
# %rax=buffer
# %rbx=buffer_length
# OUTPUT
# %rax=number
# REGS
# changes %rax, %rbx
# calls stoui
stoi:
    # save regs
    pushq %r8

    # check sign
    movq $0, %r8                # save 0 to reg
    cmpb $45, (%rax) #'-'       # cmp '-'
    jz 1f
    movq $1, %r8                # save 1 to reg
    cmpb $43, (%rax) #'+'       # cmp '+'
    jnz 2f
    1:                          # when '-' or '+'
    inc %rax                    # inc input pointer
    dec %rbx                    # dec input length
    2:
    call stoui                   # convert string to int

    cmpq $0, %r8                # cmp 0 to reg
    jnz 1f                       # if 0 negate
    neg %rax
    1:

    # retore regs
    popq %r8
    ret

# FUNCTION "stoui"
# DESCRIPTION
# Converts a string into unsigned integer
# INPUT
# %rax=buffer
# %rbx=buffer_length
# OUTPUT
# %rax=number
# REGS
# changes %rax, %rbx
stoui:
    # save regs
    pushq %r8
    pushq %r9
    pushq %r10

    xorq %r9, %r9               # clear sum reg
    1:
    movzb (%rax), %r8           # copy digit in digit reg
    subq $48, %r8               # convert ascii digit to binary digit
    #       multiply sum by 10
    movq %r9, %r10              # copy sum into copy reg
    shlq $3, %r9                # mult sum by 8
    addq %r10, %r9              # add copy to sum 
    addq %r10, %r9              # add copy to sum

    addq %r8, %r9               # add digit to sum

    dec %rbx                    # dec input length
    inc %rax                    # inc input pointer
    cmpq $0, %rbx               # loop until length is 0
    ja 1b

    movq %r9, %rax              # move return value in %rax

    # restore regs
    popq %r10
    popq %r9
    popq %r8
    ret

# FUNCTION "stod"
# DESCRIPTION
# Convert a string to a double
# INPUT
# %rax=buffer
# %rbx=buffer_len
# OUPUT
# %xmm0=number
# REGS
# changes %xmm0, %xmm1, %xmm2
# changes %rax, %rbx
stod:
    # save regs
    pushq %r8
    pushq %r9
    pushq %r10

    subq $8, %rsp               # save 8 bytes from stack

    #       make sign mask
    movl $0, (%rsp)             # save (32)0 at low
    movl $2147483648, 4(%rsp)   # save 1,(31)0 at high
    
    # check sign
    movzb (%rax), %r8
    cmpq $45, %r8
    jz 1f
    movl $0, 4(%rsp)            # save (32)0 at high 
    cmpq $43, %r8
    jnz 2f
    1:
    inc %rax
    dec %rbx
    movzb (%rax), %r8
    2:

    #       write integer part
    xorq %r9, %r9               # clear sum reg
    1:
    subq $48, %r8               # convert ascii digit to binary digit
    #   multiply sum by 10
    movq %r9, %r10              # copy sum into copy reg
    shlq $3, %r9                # mult sum by 8
    addq %r10, %r9              # add copy to sum 
    addq %r10, %r9              # add copy to sum

    addq %r8, %r9               # add digit to sum

    dec %rbx                    # dec input length
    inc %rax                    # inc input pointer
    cmpq $0, %rbx               # loop if length is 0
    jz 2f
    movzb (%rax), %r8           # copy digit in digit reg
    cmpq $46, %r8               # loop until digit='.'
    jnz 1b
    2:

    movq $10, %r8
    cvtsi2sd %r8, %xmm2
    #       write floating-point part
    dec %rbx                    # dec length because of '.'
    addq %rbx, %rax             # add length to buffer pointer
    1:
    movzb (%rax), %r8           # copy digit in digit reg
    subq $48, %r8               # convert ascii digit to binary digit
    cvtsi2sd %r8, %xmm1         # load digit in simd
    addsd %xmm1, %xmm0          # add digit to sum
    divsd %xmm2, %xmm0          # divide sum by 10

    dec %rax                    # dec buffer pointer
    dec %rbx                    # dec length
    cmpq $0, %rbx               # loop until length=0
    ja 1b

    cvtsi2sd %r9, %xmm1         # load integer part in simd
    addsd %xmm1, %xmm0          # add integer and floating-point parts

    movq (%rsp), %xmm1          # load mask
    xorpd %xmm1, %xmm0          # apply sign

    addq $8, %rsp               # return 8 bytes to stack

    popq %r10
    popq %r9
    popq %r8
    ret
