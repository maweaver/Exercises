%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

char *endp;
extern char *yytext;

int yylex();
void yyerror(char *s);

%}

%token TOKEN_EOF
%token TOKEN_DEF
%token TOKEN_EXTERN
%token TOKEN_IDENTIFIER
%token TOKEN_NUMBER
%token TOKEN_OUTPUT

%start statement

%left '+' '-'
%left '*' '/'
%left ','

%%

statement : extern statement
          | function statement
          | output
          ;

identifier: TOKEN_IDENTIFIER
            { $$ = ast_identifier(strdup(yytext)); }

extern : TOKEN_EXTERN prototype
         { $$ = ast_extern($2); }
       ;

function : TOKEN_DEF prototype expression
           { $$ = ast_function($2, $3); }

output : TOKEN_OUTPUT expression
         { $$ = ast_output($2); }

prototype : identifier '(' ')'
            { $$ = ast_prototype($1, -1); }
          | identifier '(' prototype_args ')'
            { $$ = ast_prototype($1, $3); }
          ;

prototype_args : identifier
                 { $$ = ast_prototype_arg($1, -1); }
               | identifier ',' prototype_args
                 { $$ = ast_prototype_arg($1, $3); }
               ;

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

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

