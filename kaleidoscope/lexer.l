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
output        return TOKEN_OUTPUT;
{IDENTIFIER}  identifier_str = yytext; return TOKEN_IDENTIFIER;
{SYMBOL}      return *yytext;
<<EOF>>       return TOKEN_EOF;

%%

/*
int main(int argc, char** argv) {

	int token = 0;
	while(token != TOKEN_EOF) {
		token = yylex();
		
		switch(token) {
			case NUMBER: printf("TOKEN_NUMBER"); break;
			case DEF: printf("TOKEN_DEF"); break;
			case EXTERN: printf("TOKEN_EXTERN"); break;
			case IDENTIFIER: printf("IDENTIFIER: %s", identifier_str); break;
			case EOF: printf("TOKEN_EOF"); break;
			default: printf("SYMBOL: %c", token); break;
		}
		printf("\n");
	}
}*/

