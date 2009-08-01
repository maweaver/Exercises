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
		stmt.accept(TraversalOrder.preorder, this);
		fwritefln(outfile, "}");
	}
	
	void visit(Statement stmt) {
	}
	
	void visit(ASTNode rootNode) {
	}
	
	void visit(Number number) {
		addNode(number, std.string.toString(number.val));
	}
	
	void visit(Variable variable) {
		addNode(variable, variable.name);
	}
	
	void visit(BinaryExpression binaryExpression) {
		addNode(binaryExpression, std.string.toString(binaryExpression.operation), "circle");
	}
	
	void visit(Call call) {
		addNode(call, call.callee, "box");
	}
	
	void visit(CallArg callArg) {
	}
	
	void visit(Function functionNode) {
		addNode(functionNode, "Function", "box");
	}
	
	void visit(Prototype prototype) {
		addNode(prototype, prototype.name);
	}
	
	void visit(PrototypeArg prototypeArg) {
		addNode(prototypeArg, prototypeArg.name);
	}
	
	void visit(Extern externNode) {
		addNode(externNode, "Extern", "box");
	}
	
	void unvisit(ASTNode node) {
		if(parentNodes.peek == node) {
			parentNodes.pop();
		}
	}
}
