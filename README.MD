### STDASM

**purpose:** A collection of assembly code that may be frequently used.

**composition**

A stdasm/ folder with many sub-folders like stdasm/string/ each containing .s files.

**compilation**

Running make compiles **libcmple.c** and each **.s file** from each sub-folder into .o file into stdasm/.

If any **.s files** are compiled, ./libcmple.out is run which uses the **ar** utility to combine .o files into .a files

**info**

XMM/YMM, GP input or FPU registers could be changed when calling functions.

Input from the stack isn't cleared
