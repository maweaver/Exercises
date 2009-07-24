import ast;
import std.math;
import std.stdio;
import std.string;

class DotGen: ASTNodeVisitor {
	private:
	
	ASTNode[] parentNodes;
	_iobuf *outfile;
	
	void addNode(ASTNode node, string label, string shape = "oval") {
		fwritefln(outfile, "%d [label=\"%s\", shape=\"%s\"];", 
			node.id, label, shape);
		
		if(parentNodes.length > 0) {
			fwritefln(outfile, "%d -> %d;", 
				parentNodes[parentNodes.length - 1].id, 
				node.id);
		}
		
		parentNodes.length = parentNodes.length + 1;
		parentNodes[parentNodes.length - 1] = node;
	}
	
	public:
	
	this(_iobuf *outfile) {
		this.outfile = outfile;
	}
	
	void visit(ASTRootNode rootNode) {
		fwritefln(outfile, "digraph G {");
		addNode(rootNode, "Program", "box");
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
	
	void visit(ASTNode node) {
	}
	
	void unvisit(ASTNode node) {
		if(parentNodes.length == 1) {
			fwritefln(outfile, "}");
		} else if(parentNodes[parentNodes.length - 1] == node) {
			parentNodes.length = parentNodes.length - 1;
		}
	}
}
