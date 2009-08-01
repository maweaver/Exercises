import std.c.stdio;
import std.stdio;
import std.string;

import ast;
import llvmirgen;
import dotgen;

extern(C) int yyparse();

void main() {
	yyparse();
	writefln("%d", ast.statements.length);
	/*auto rootNode = ast.statements.head;
	
	auto dotFile = fopen("ast.dot", "w");
	auto dg = new DotGen(dotFile);
	rootNode.accept(TraversalOrder.preorder, dg);
	fclose(dotFile);*/
	
//	auto llvmIrGen = new LlvmIrGen();
//	auto moduleRef = llvmIrGen.generateModule("kaleidoscope", rootNode);
}
