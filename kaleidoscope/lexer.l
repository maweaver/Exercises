%option noyywrap

%{
#include "parser.tab.h"

char *identifier_str;

%}

IDENTIFIER    [a-zA-Z][a-zA-Z0-9]*
NUMBER        [0-9.]+
WHITESPACE    [ \t\r\n]
SYMBOL        [^a-zA-z0-9.]
COMMENT       #.*

%%

{WHITESPACE}  /* Do nothing */
{COMMENT}     /* Do nothing */
{NUMBER}      return TOKEN_NUMBER;
def           return TOKEN_DEF;
extern        return TOKEN_EXTERN;
input         return TOKEN_INPUT;
output        return TOKEN_OUTPUT;
if            return TOKEN_IF;
then          return TOKEN_THEN;
else          return TOKEN_ELSE;
{IDENTIFIER}  identifier_str = yytext; return TOKEN_IDENTIFIER;
{SYMBOL}      return *yytext;
<<EOF>>       return TOKEN_EOF;
