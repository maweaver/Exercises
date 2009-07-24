#!/bin/bash

/home/matt/Apps/dmd/linux/bin/dmd -gc -c ast.d
/home/matt/Apps/dmd/linux/bin/dmd -gc -c main.d
/home/matt/Apps/dmd/linux/bin/dmd -gc -c dotgen.d
/home/matt/Apps/dmd/linux/bin/dmd -gc -c llvmirgen.d
bison --defines=y.tab.h --output=y.tab.c parser.yacc
flex --outfile=lexer.c lexer.flex
gcc -m32 -g -c y.tab.c
gcc -m32 -g -c lexer.c
gcc -m32 -o kaleidoscope ast.o y.tab.o lexer.o dotgen.o llvmirgen.o main.o -L/home/matt/Apps/dmd/linux/lib/ -L/usr/lib/llvm -L/usr/lib/gcc/i586-redhat-linux/4.4.0 -lphobos -lpthread -lm -lLLVMCore -lLLVMSupport -lLLVMSystem -lstdc++
./kaleidoscope
dot -Tpng -o ast.png ast.dot
