#!/bin/bash

/home/matt/Apps/dmd/linux/bin/dmd -gc -c ast.d
/home/matt/Apps/dmd/linux/bin/dmd -gc -c main.d
bison --defines=y.tab.h --output=y.tab.c parser.yacc
flex --outfile=lexer.c lexer.flex
gcc -m32 -g -c y.tab.c
gcc -m32 -g -c lexer.c
gcc -m32 ast.o y.tab.o lexer.o main.o -L/home/matt/Apps/dmd/linux/lib/ -lphobos -lpthread -lm
