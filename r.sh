#!/bin/bash

# Program: Electricity
# Michelle Pham
# mp28jam@csu.fullerton.edu
# CWID# 867434789
# CPSC 240-03
# This file is the script file for the program.
rm *o
rm *out

echo "Assembling the source file faraday.asm..."
nasm -f elf64 -l faraday.lis -o faraday.o faraday.asm

echo "Assembling the source file edison.asm..."
nasm -f elf64 -l edison.lis -o edison.o edison.asm

echo "Assembling the source file atof.asm..."
nasm -f elf64 -l atof.lis -o atof.o atof.asm

echo "Assembling the source file int_to_str.asm..."
nasm -f elf64 -l int_to_str.lis -o int_to_str.o int_to_str.asm

echo "Assembling the source file isfloat.asm..."
nasm -f elf64 -l isfloat.lis -o isfloat.o isfloat.asm

echo "Assembling the source file tesla.asm..."
nasm -f elf64 -l tesla.lis -o tesla.o tesla.asm

echo "Linking the object modules to create an executable file..."
ld faraday.o edison.o atof.o tesla.o -o calc.out int_to_str.o isfloat.o -o calc.out

echo "Executing the program..."
./calc.out
