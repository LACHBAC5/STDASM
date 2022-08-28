.section .data
.section .bss
.section .text
# dependencies
.extern _start
.extern itos
.extern dtos
# formated print
.globl print

# FUNCTION PRINT
# DESCRIPTION
# Print a formated string
# INPUT
# %rax=buffer
# %rbx=buffer_length
# values=stack
# OUTPUT
# Terminal text
# REGS
# changes %rax, %rbx

print:
    pushq %rbp
    movq %rsp, %rbp
    addq $8, %rbp
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %r8 
    pushq %r9
    pushq %r10
    pushq %r11

    subq $32, %rsp

    movq %rax, %r8
    movq %rbx, %r9
    xorq %r10, %r10

    jmp 1f
    2:
    movq $1, %rax
    movq $1, %rdi
    movq %r8, %rsi
    movq %r10, %rdx
    syscall

    inc %r10
    addq %r10, %r8
    subq %r10, %r9
    xorq %r10, %r10
    
    movzb (%r8, %r10, 1), %r11
    inc %r8
    cmpq $100, %r11 #'d'
    jz 5f
    cmpq $105, %r11 #'i'
    jz 4f

    5:
    addq $8, %rbp
    movq (%rbp), %rax
    movq %rsp, %rbx
    call dtos
    jmp 3f
    4:
    add $8, %rbp
    movq (%rbp), %rax
    movq %rsp, %rbx
    call itos

    3:
    movq %rax, %rdx
    movq $1, %rax
    movq $1, %rdi
    movq %rsp, %rsi
    syscall

    1:
    movzb (%r8, %r10, 1), %r11
    cmpq $37, %r11
    jz 2b

    inc %r10
    cmpq %r10, %r9
    ja 1b

    movq $1, %rax
    movq $1, %rdi
    movq %r8, %rsi
    movq %r10, %rdx
    syscall

    addq $32, %rsp

    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rdi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbp
    ret
