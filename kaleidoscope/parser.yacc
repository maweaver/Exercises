%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

char *endp;
extern char *yytext;
%}

%token TOKEN_EOF
%token TOKEN_DEF
%token TOKEN_EXTERN
%token TOKEN_IDENTIFIER
%token TOKEN_NUMBER

%start expression

%left '+' '-'
%left '*' '/'
%left ','

%%

identifier: TOKEN_IDENTIFIER
            { $$ = ast_identifier(strdup(yytext)); }

call : identifier '(' ')'
       { $$ = ast_call($1, -1); }
     | identifier '(' call_args ')'
       { $$ = ast_call($1, $3); }
     ;

call_args : expression
            { $$ = ast_call_arg($1, -1); }
          | expression ',' call_args
            { $$ = ast_call_arg($1, $3); }
          ;

expression : expression '+' expression
             { $$ = ast_binary_expression('+', $1, $3); }
           | expression '-' expression
             { $$ = ast_binary_expression('-', $1, $3); }
           | expression '*' expression
             { $$ = ast_binary_expression('*', $1, $3); }
           | expression '/' expression
             { $$ = ast_binary_expression('/', $1, $3); }
           | '(' expression ')'
             { $$ = $2; }
           | identifier
             { $$ = ast_variable($1); }
           | TOKEN_NUMBER
             { $$ = ast_number(strtod(yytext, &endp)); }
           | call
           ;

%%

yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

