.section .data
.section .bss
.section .text
.extern _start
.globl pow

# FUNCTION "pow"
# DESCRIPTION
# Raises a number to a power
# INPUT
# %st(0)=number
# %st(1)=power
# OUTPUT
# %st(0)=new number
# NOTE
# very expensive
pow:
    fyl2x               # %st(0)=log2(%st(0)^%st(1)) && pop
    fld %st(0)          # copy %st(0)
    frndint             # %st(0)=int(%st(0))
    fxch %st(1)         # swap(%st(0), %st(1))
    fsub %st(1), %st(0) # %st(0)-=%st(1)
    f2xm1               # %st(0)=2^%st(0)-1
    fld1                # push 1.0
    faddp               # %st(1)+=%st(0) && pop
    fscale              # %st(0)*=2^%st(1)
    fstp %st(1)         # %st(1)=%st(0) && pop
    ret
