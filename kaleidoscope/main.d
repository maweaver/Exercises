import std.stdio;
import ast;

extern(C) int yyparse();

void main() {
	yyparse();
	foreach(statement; ast.statements) {
		writefln(statement.toString(0, false));
	}
}
