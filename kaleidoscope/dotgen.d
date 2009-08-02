import ast;
import stack;

import std.math;
import std.stdio;
import std.string;

class DotGen: ASTNodeVisitor {
	
	private:

	ASTNode programNode;
	Stack!(ASTNode) parentNodes;
	_iobuf *outfile;
	
	void addNode(ASTNode node, string label, string shape = "oval") {
		fwritefln(outfile, "%d [label=\"%s\", shape=\"%s\"];", 
			node.id, label, shape);
		
		if(parentNodes.length > 0) {
			fwritefln(outfile, "%d -> %d;", 
				parentNodes.peek.id, 
				node.id);
		}
		
		parentNodes.push(node);
	}
	
	public:
	
	this(_iobuf *outfile) {
		this.outfile = outfile;
		this.parentNodes = new Stack!(ASTNode)();
	}
	
	void generateDot(Statement stmt) {
		fwritefln(outfile, "digraph G {");
		programNode = new ASTNode(ast.nextId());
		addNode(programNode, "Program", "box");
		parentNodes.push(programNode);
		stmt.accept(this);
		fwritefln(outfile, "}");
	}
	
	void previsit(BinaryExpression binaryExpression) {
		addNode(binaryExpression, std.string.toString(binaryExpression.operation), "circle");
	}
	
	void postvisit(BinaryExpression n) {
		parentNodes.pop();
	}
	
	void previsit(BooleanExpression booleanExpression) {
		addNode(booleanExpression, std.string.toString(booleanExpression.operation), "circle");
	}
	
	void postvisit(BooleanExpression n) {
		parentNodes.pop();
	}
	
	void previsit(Call call) {
		addNode(call, call.callee, "box");
	}
	
	void postvisit(Call n) {
		parentNodes.pop();
	}
	
	void previsit(Extern externNode) {
		addNode(externNode, "Extern", "box");
	}
	
	void postvisit(Extern n) {
		parentNodes.pop();
	}
	
	void previsit(Function functionNode) {
		addNode(functionNode, "Function", "box");
	}
	
	void postvisit(Function n) {
		parentNodes.pop();
	}
	
	void previsit(If ifNode) {
		addNode(ifNode, "If", "box");
	}
	
	void postvisit(If n) {
		parentNodes.pop();
	}
	
	void previsit(Input inputNode) {
		addNode(inputNode, "Input", "box");
	}
	
	void postvisit(Input n) {
		parentNodes.pop();
	}
	
	void previsit(ThenElse thenElseNode) {
		addNode(thenElseNode, "Then/Else", "box");
	}
	
	void postvisit(ThenElse n) {
		parentNodes.pop();
	}
	
	void previsit(Number number) {
		addNode(number, std.string.toString(number.val));
	}
	
	void postvisit(Number n) {
		parentNodes.pop();
	}
	
	void previsit(Output outputNode) {
		addNode(outputNode, "Output", "box");
	}
	
	void postvisit(Output n) {
		parentNodes.pop();
	}
	
	void previsit(Prototype prototype) {
		addNode(prototype, prototype.name);
	}
	
	void postvisit(Prototype n) {
		parentNodes.pop();
	}
	
	void previsit(PrototypeArg prototypeArg) {
		addNode(prototypeArg, prototypeArg.name);
	}
	
	void postvisit(PrototypeArg n) {
		parentNodes.pop();
	}
	
	void previsit(Variable variable) {
		addNode(variable, variable.name);
	}
	
	void postvisit(Variable n) {
		parentNodes.pop();
	}
}
