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
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_IDENTIFIER
%token TOKEN_NUMBER
%token TOKEN_INPUT
%token TOKEN_OUTPUT

%start statement

%left '<' '=' '>'
%left '+' '-'
%left '*' '/'
%left ','

%%

statement : extern statement
          | function statement
          | output statement
          | TOKEN_EOF
          ;

identifier: TOKEN_IDENTIFIER
            { $$ = ast_identifier(strdup(yytext)); }

extern : TOKEN_EXTERN prototype
         { $$ = ast_extern($2); }
       ;

function : TOKEN_DEF prototype expression
           { $$ = ast_function($2, $3); }
         ;

input : TOKEN_INPUT '(' ')'
        { $$ = ast_input(); }
      ;

output : TOKEN_OUTPUT expression
         { $$ = ast_output($2); }
       ;

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
           | if
           | input
           ;

boolean_expression : expression '<' expression
                     { $$ = ast_boolean_expression('<', $1, $3); }
                   | expression '=' expression
                     { $$ = ast_boolean_expression('=', $1, $3); }
                   | expression '>' expression
                     { $$ = ast_boolean_expression('>', $1, $3); }
                   ;

if : TOKEN_IF '(' boolean_expression ')' then_else
     { $$ = ast_if($3, $5); }
   ;

then_else : TOKEN_THEN expression TOKEN_ELSE expression
            { $$ = ast_then_else($2, $4); }
          ;
%%

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

