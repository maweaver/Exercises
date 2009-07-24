import std.stdio;
import std.c.stdio;
import ast;
import llvmirgen;
import dotgen;

extern(C) int yyparse();

void main() {
	yyparse();
	auto rootNode = ast.getRootNode();
	
	auto dotFile = fopen("ast.dot", "w");
	auto dg = new DotGen(dotFile);
	rootNode.visit(dg);
	fclose(dotFile);
	
	auto llvmIrGen = new LlvmIrGen();
	auto moduleRef = llvmIrGen.generateModule("kaleidoscope", rootNode);
}
