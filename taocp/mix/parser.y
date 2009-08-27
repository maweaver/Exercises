%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *endp;
extern char *yytext;

void yyerror(char *s);

int mixal_number(int);
int mixal_symbol_decl(char *);
int mixal_symbol_ref(char *);
int mixal_self();
int mixal_eq(int, int);
int mixal_operator(int, int, int, int);

%}

%token TOKEN_LOCAL_SYMBOL
%token TOKEN_IDENTIFIER
%token TOKEN_NUMBER

%token TOKEN_LPAREN
%token TOKEN_RPAREN
%token TOKEN_EQ
%token TOKEN_MINUS
%token TOKEN_PLUS
%token TOKEN_MUL
%token TOKEN_FRAC
%token TOKEN_DIV
%token TOKEN_RANGE
%token TOKEN_COMMA
%token TOKEN_NEWLINE

%token TOKEN_OP_NOP
%token TOKEN_OP_ADD
%token TOKEN_OP_FADD
%token TOKEN_OP_SUB
%token TOKEN_OP_FSUB
%token TOKEN_OP_MUL
%token TOKEN_OP_FMUL
%token TOKEN_OP_DIV
%token TOKEN_OP_FDIV
%token TOKEN_OP_NUM
%token TOKEN_OP_CHAR
%token TOKEN_OP_HLT
%token TOKEN_OP_SLA
%token TOKEN_OP_SRA
%token TOKEN_OP_SLAX
%token TOKEN_OP_SRAX
%token TOKEN_OP_SLC
%token TOKEN_OP_SRC
%token TOKEN_OP_MOVE
%token TOKEN_OP_LDA
%token TOKEN_OP_LD1
%token TOKEN_OP_LD2
%token TOKEN_OP_LD3
%token TOKEN_OP_LD4
%token TOKEN_OP_LD5
%token TOKEN_OP_LD6
%token TOKEN_OP_LDX
%token TOKEN_OP_LDAN
%token TOKEN_OP_LD1N
%token TOKEN_OP_LD2N
%token TOKEN_OP_LD3N
%token TOKEN_OP_LD4N
%token TOKEN_OP_LD5N
%token TOKEN_OP_LD6N
%token TOKEN_OP_LDXN
%token TOKEN_OP_STA
%token TOKEN_OP_ST1
%token TOKEN_OP_ST2
%token TOKEN_OP_ST3
%token TOKEN_OP_ST4
%token TOKEN_OP_ST5
%token TOKEN_OP_ST6
%token TOKEN_OP_STX
%token TOKEN_OP_STJ
%token TOKEN_OP_STZ
%token TOKEN_OP_JBUS
%token TOKEN_OP_IOC
%token TOKEN_OP_IN
%token TOKEN_OP_OUT
%token TOKEN_OP_JRED
%token TOKEN_OP_JMP
%token TOKEN_OP_JSJ
%token TOKEN_OP_JOV
%token TOKEN_OP_JNOV
%token TOKEN_OP_JL
%token TOKEN_OP_JE
%token TOKEN_OP_JG
%token TOKEN_OP_JGE
%token TOKEN_OP_JNE
%token TOKEN_OP_JLE
%token TOKEN_OP_JAN
%token TOKEN_OP_JAZ
%token TOKEN_OP_JAP
%token TOKEN_OP_JANN
%token TOKEN_OP_JANZ
%token TOKEN_OP_JANP
%token TOKEN_OP_J1N
%token TOKEN_OP_J1Z
%token TOKEN_OP_J1P
%token TOKEN_OP_J1NN
%token TOKEN_OP_J1NZ
%token TOKEN_OP_J1NP
%token TOKEN_OP_J2N
%token TOKEN_OP_J2Z
%token TOKEN_OP_J2P
%token TOKEN_OP_J2NN
%token TOKEN_OP_J2NZ
%token TOKEN_OP_J2NP
%token TOKEN_OP_J3N
%token TOKEN_OP_J3Z
%token TOKEN_OP_J3P
%token TOKEN_OP_J3NN
%token TOKEN_OP_J3NZ
%token TOKEN_OP_J3NP
%token TOKEN_OP_J4N
%token TOKEN_OP_J4Z
%token TOKEN_OP_J4P
%token TOKEN_OP_J4NN
%token TOKEN_OP_J4NZ
%token TOKEN_OP_J4NP
%token TOKEN_OP_J5N
%token TOKEN_OP_J5Z
%token TOKEN_OP_J5P
%token TOKEN_OP_J5NN
%token TOKEN_OP_J5NZ
%token TOKEN_OP_J5NP
%token TOKEN_OP_J6N
%token TOKEN_OP_J6Z
%token TOKEN_OP_J6P
%token TOKEN_OP_J6NN
%token TOKEN_OP_J6NZ
%token TOKEN_OP_J6NP
%token TOKEN_OP_JXN
%token TOKEN_OP_JXZ
%token TOKEN_OP_JXP
%token TOKEN_OP_JXNN
%token TOKEN_OP_JXNZ
%token TOKEN_OP_JXNP
%token TOKEN_OP_INCA
%token TOKEN_OP_DECA
%token TOKEN_OP_ENTA
%token TOKEN_OP_ENNA
%token TOKEN_OP_INC1
%token TOKEN_OP_DEC1
%token TOKEN_OP_ENT1
%token TOKEN_OP_ENN1
%token TOKEN_OP_INC2
%token TOKEN_OP_DEC2
%token TOKEN_OP_ENT2
%token TOKEN_OP_ENN2
%token TOKEN_OP_INC3
%token TOKEN_OP_DEC3
%token TOKEN_OP_ENT3
%token TOKEN_OP_ENN3
%token TOKEN_OP_INC4
%token TOKEN_OP_DEC4
%token TOKEN_OP_ENT4
%token TOKEN_OP_ENN4
%token TOKEN_OP_INC5
%token TOKEN_OP_DEC5
%token TOKEN_OP_ENT5
%token TOKEN_OP_ENN5
%token TOKEN_OP_INC6
%token TOKEN_OP_DEC6
%token TOKEN_OP_ENT6
%token TOKEN_OP_ENN6
%token TOKEN_OP_INCX
%token TOKEN_OP_DECX
%token TOKEN_OP_ENTX
%token TOKEN_OP_ENNX
%token TOKEN_OP_CMPA
%token TOKEN_OP_FCMP
%token TOKEN_OP_CMP1
%token TOKEN_OP_CMP2
%token TOKEN_OP_CMP3
%token TOKEN_OP_CMP4
%token TOKEN_OP_CMP5
%token TOKEN_OP_CMP6
%token TOKEN_OP_CMPX

%token TOKEN_EQU
%token TOKEN_ORIG
%token TOKEN_CON
%token TOKEN_ALF
%token TOKEN_END

%start program

%%

number : TOKEN_NUMBER

self : TOKEN_MUL

symbol : TOKEN_LOCAL_SYMBOL
         { $$ = mixal_symbol_decl(strdup(yytext)); }
       | TOKEN_IDENTIFIER
         { $$ = mixal_symbol_decl(strdup(yytext)); }

atomic_expression : number
                    { $$ = (int) strtol(yytext, &endp, 10); }
                  | TOKEN_IDENTIFIER
                    { $$ = mixal_symbol_ref(strdup(yytext)); }
                  | TOKEN_LOCAL_SYMBOL
                    { $$ = mixal_symbol_ref(strdup(yytext)); }
                  | self
                    { $$ = mixal_self(); }

expression : atomic_expression
             { $$ = $1; }
           | TOKEN_PLUS atomic_expression
             { $$ = $2; }
           | TOKEN_MINUS atomic_expression
             { $$ = -$2; }
           | expression TOKEN_PLUS atomic_expression
             { $$ = $1 + $3; }
           | expression TOKEN_MINUS atomic_expression
             { $$ = $1 - $3; }
           | expression TOKEN_MUL atomic_expression
             { $$ = $1 * $3; }
           | expression TOKEN_DIV atomic_expression
             { $$ = $1 / $3; }
           | expression TOKEN_FRAC atomic_expression
           | expression TOKEN_RANGE atomic_expression

a_part : expression
         { $$ = $1; }
       | symbol
         { $$ = $1; }

i_part : TOKEN_COMMA expression
         { $$ = $2; }

f_part : TOKEN_LPAREN expression TOKEN_RPAREN
         { $$ = $2; }

w_value : expression
          { $$ = $1; }
        | expression f_part
        | w_value TOKEN_COMMA expression f_part
        | TOKEN_EQ expression TOKEN_EQ

op : TOKEN_OP_NOP
   | TOKEN_OP_ADD
   | TOKEN_OP_FADD
   | TOKEN_OP_SUB
   | TOKEN_OP_FSUB
   | TOKEN_OP_MUL
   | TOKEN_OP_FMUL
   | TOKEN_OP_DIV
   | TOKEN_OP_FDIV
   | TOKEN_OP_NUM
   | TOKEN_OP_CHAR
   | TOKEN_OP_HLT
   | TOKEN_OP_SLA
   | TOKEN_OP_SRA
   | TOKEN_OP_SLAX
   | TOKEN_OP_SRAX
   | TOKEN_OP_SLC
   | TOKEN_OP_SRC
   | TOKEN_OP_MOVE
   | TOKEN_OP_LDA
   | TOKEN_OP_LD1
   | TOKEN_OP_LD2
   | TOKEN_OP_LD3
   | TOKEN_OP_LD4
   | TOKEN_OP_LD5
   | TOKEN_OP_LD6
   | TOKEN_OP_LDX
   | TOKEN_OP_LDAN
   | TOKEN_OP_LD1N
   | TOKEN_OP_LD2N
   | TOKEN_OP_LD3N
   | TOKEN_OP_LD4N
   | TOKEN_OP_LD5N
   | TOKEN_OP_LD6N
   | TOKEN_OP_LDXN
   | TOKEN_OP_STA
   | TOKEN_OP_ST1
   | TOKEN_OP_ST2
   | TOKEN_OP_ST3
   | TOKEN_OP_ST4
   | TOKEN_OP_ST5
   | TOKEN_OP_ST6
   | TOKEN_OP_STX
   | TOKEN_OP_STJ
   | TOKEN_OP_STZ
   | TOKEN_OP_JBUS
   | TOKEN_OP_IOC
   | TOKEN_OP_IN
   | TOKEN_OP_OUT
   | TOKEN_OP_JRED
   | TOKEN_OP_JMP
   | TOKEN_OP_JSJ
   | TOKEN_OP_JOV
   | TOKEN_OP_JNOV
   | TOKEN_OP_JL
   | TOKEN_OP_JE
   | TOKEN_OP_JG
   | TOKEN_OP_JGE
   | TOKEN_OP_JNE
   | TOKEN_OP_JLE
   | TOKEN_OP_JAN
   | TOKEN_OP_JAZ
   | TOKEN_OP_JAP
   | TOKEN_OP_JANN
   | TOKEN_OP_JANZ
   | TOKEN_OP_JANP
   | TOKEN_OP_J1N
   | TOKEN_OP_J1Z
   | TOKEN_OP_J1P
   | TOKEN_OP_J1NN
   | TOKEN_OP_J1NZ
   | TOKEN_OP_J1NP
   | TOKEN_OP_J2N
   | TOKEN_OP_J2Z
   | TOKEN_OP_J2P
   | TOKEN_OP_J2NN
   | TOKEN_OP_J2NZ
   | TOKEN_OP_J2NP
   | TOKEN_OP_J3N
   | TOKEN_OP_J3Z
   | TOKEN_OP_J3P
   | TOKEN_OP_J3NN
   | TOKEN_OP_J3NZ
   | TOKEN_OP_J3NP
   | TOKEN_OP_J4N
   | TOKEN_OP_J4Z
   | TOKEN_OP_J4P
   | TOKEN_OP_J4NN
   | TOKEN_OP_J4NZ
   | TOKEN_OP_J4NP
   | TOKEN_OP_J5N
   | TOKEN_OP_J5Z
   | TOKEN_OP_J5P
   | TOKEN_OP_J5NN
   | TOKEN_OP_J5NZ
   | TOKEN_OP_J5NP
   | TOKEN_OP_J6N
   | TOKEN_OP_J6Z
   | TOKEN_OP_J6P
   | TOKEN_OP_J6NN
   | TOKEN_OP_J6NZ
   | TOKEN_OP_J6NP
   | TOKEN_OP_JXN
   | TOKEN_OP_JXZ
   | TOKEN_OP_JXP
   | TOKEN_OP_JXNN
   | TOKEN_OP_JXNZ
   | TOKEN_OP_JXNP
   | TOKEN_OP_INCA
   | TOKEN_OP_DECA
   | TOKEN_OP_ENTA
   | TOKEN_OP_ENNA
   | TOKEN_OP_INC1
   | TOKEN_OP_DEC1
   | TOKEN_OP_ENT1
   | TOKEN_OP_ENN1
   | TOKEN_OP_INC2
   | TOKEN_OP_DEC2
   | TOKEN_OP_ENT2
   | TOKEN_OP_ENN2
   | TOKEN_OP_INC3
   | TOKEN_OP_DEC3
   | TOKEN_OP_ENT3
   | TOKEN_OP_ENN3
   | TOKEN_OP_INC4
   | TOKEN_OP_DEC4
   | TOKEN_OP_ENT4
   | TOKEN_OP_ENN4
   | TOKEN_OP_INC5
   | TOKEN_OP_DEC5
   | TOKEN_OP_ENT5
   | TOKEN_OP_ENN5
   | TOKEN_OP_INC6
   | TOKEN_OP_DEC6
   | TOKEN_OP_ENT6
   | TOKEN_OP_ENN6
   | TOKEN_OP_INCX
   | TOKEN_OP_DECX
   | TOKEN_OP_ENTX
   | TOKEN_OP_ENNX
   | TOKEN_OP_CMPA
   | TOKEN_OP_FCMP
   | TOKEN_OP_CMP1
   | TOKEN_OP_CMP2
   | TOKEN_OP_CMP3
   | TOKEN_OP_CMP4
   | TOKEN_OP_CMP5
   | TOKEN_OP_CMP6
   | TOKEN_OP_CMPX

operator : op a_part i_part f_part
           { $$ = mixal_operator($1, $2, $3, $4); }
         | op a_part i_part
           { $$ = mixal_operator($1, $2, $3, 0); }
         | op a_part f_part
           { $$ = mixal_operator($1, $2, 0, $3); }
         | op i_part f_part
           { $$ = mixal_operator($1, 0, $2, $3); }
         | op a_part
           { $$ = mixal_operator($1, $2, 0, 0); }
         | op i_part
           { $$ = mixal_operator($1, 0, $2, 0); }
         | op f_part
           { $$ = mixal_operator($1, 0, 0, $2); }

equ : symbol TOKEN_EQU w_value
      { $$ = mixal_eq($1, $3); }

orig : TOKEN_ORIG w_value
       { $$ = mixal_orig($2); }

con : TOKEN_CON w_value

alf : TOKEN_ALF w_value

end : TOKEN_END w_value

statement : operator
          | symbol operator
          | equ
          | orig
          | symbol orig
          | con
          | symbol con
          | alf
          | symbol alf
          | end
          | symbol end

program : statement
        | statement program
        
%%

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}
