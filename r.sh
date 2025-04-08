#!/bin/bash

echo "Assembling the source file faraday.asm..."
nasm -f elf64 -l faraday.lis -o faraday.o faraday.asm

echo "Assembling the source file edison.asm..."
nasm -f elf64 -l edison.lis -o edison.o edison.asm

echo "Assembling the source file atof.asm..."
nasm -f elf64 -l atof.lis -o atof.o atof.asm

echo "Assembling the source file ftoa.asm..."
nasm -f elf64 -l ftoa.lis -o ftoa.o ftoa.asm

echo "Assembling the source file tesla.asm..."
nasm -f elf64 -l tesla.lis -o tesla.o tesla.asm

echo "Linking the object modules to create an executable file..."
ld faraday.o edison.o atof.o tesla.o ftoa.o -o calc.out

echo "Executing the program..."
./calc.out
