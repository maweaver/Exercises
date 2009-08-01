import std.gc;
import std.math;
import std.c.stdio;
import std.stdio;
import std.string;

import stack;
import visitor;

interface ASTNodeVisitor {
	
	void visit(Statement stmt);
	void visit(Number number);
	void visit(Variable variable);
	void visit(BinaryExpression binaryExpression);
	void visit(Call call);
	void visit(CallArg callArg);
	void visit(Function functionNode);
	void visit(Prototype prototype);
	void visit(PrototypeArg prototypeArg);
	void visit(Extern externNode);
	void visit(ASTNode node);
	
	void unvisit(ASTNode node);
}

enum TraversalOrder {

	preorder,
	inorder,
	postorder
}

class ASTNode {
	public:
	
	int id;
	ASTNode left;
	ASTNode right;
	
	this(int id, ASTNode left = null, ASTNode right = null) {
		this.id = id;
		this.left = left;
		this.right = right;
	}
	
	void accept(TraversalOrder order, ASTNodeVisitor v) {
		if(order == TraversalOrder.preorder) {
			v.visit(this);
		}
		if(left) {
			left.accept(order, v);
		}
		if(order == TraversalOrder.inorder) {
			v.visit(this);
		}
		if(right) {
			right.accept(order, v);
		}
		if(order == TraversalOrder.postorder) {
			v.visit(this);
		}
		v.unvisit(this);
	}
}

class Expression: ASTNode {
	this(int id, ASTNode left = null, ASTNode right = null) {
		super(id, left, right);
	}
	
}

class Statement: ASTNode {
	public:
	
	ASTNode statement() {
		return left;
	}

	Statement nextStatement() {
		return cast(Statement) right;
	}
	void nextStatement(Statement statement) {
		right = statement;
	}
		
	this(int id, ASTNode statement, Statement nextStatement = null) {
		super(id, statement, nextStatement);
	}
}

class Identifier: Expression {
	
	public:
	
	string name;
	
	this(int id, string name) {
		super(id);
		this.name = name;
	}
}

class Number: Expression {
	public:
	
	double val;

	this(int id, double val) {
		super(id);
		this.val = val;
	}
}

class Variable: Expression {
	public:
	
	string name;
	
	this(int id, string name) {
		super(id);
		this.name = name;
	}
}

class BinaryExpression: Expression {
	public:
	
	char operation;
	
	Expression lhs() {
		return cast(Expression) left;
	}
	
	Expression rhs() {
		return cast(Expression) right;
	}
	
	this(int id, char operation, Expression left, Expression right) {
		super(id, left, right);
		this.operation = operation;
	}
}

class Call: Expression {
	public:
	
	string callee;
	
	CallArg args() {
		return cast(CallArg) left;
	}
	
	CallArg[] flatArgs() {
		CallArg[] ret;
		CallArg curArg = args;
		while(curArg) {
			ret.length = ret.length + 1;
			ret[ret.length - 1] = curArg;
			curArg = curArg.nextArg;
		}
		return ret;
	}
	
	this(int id, string callee) {
		super(id);
		this.callee = callee;
	}
	
	this(int id, string callee, CallArg args) {
		super(id, args);
		this.callee = callee;
	}
}

class CallArg: Expression {
	public:
	
	Expression value() {
		return cast(Expression) left;
	}
	
	CallArg nextArg() {
		return cast(CallArg) right;
	}
	
	this(int id, Expression value) {
		super(id, value);
	}
	
	this(int id, Expression value, CallArg nextArg) {
		super(id, value, nextArg);
	}
	
	mixin Acceptor!(value, nextArg, ASTNodeVisitor);
}

class Prototype: ASTNode {
	public:
	
	string name;
	PrototypeArg args() {
		return cast(PrototypeArg) left;
	}
	
	PrototypeArg[] flatArgs() {
		PrototypeArg[] ret;
		PrototypeArg curArg = args;
		while(curArg) {
			ret.length = ret.length + 1;
			ret[ret.length - 1] = curArg;
			curArg = curArg.nextArg;
		}
		return ret;
	}

	this(int id, string name) {
		super(id);
		this.name = name;
	}
	
	this(int id, string name, PrototypeArg args) {
		super(id, args);
		this.name = name;
	}
}

class PrototypeArg: ASTNode {
	public:
	
	string name;
	PrototypeArg nextArg() {
		return cast(PrototypeArg) left;
	}
	
	this(int id, string name) {
		super(id);
		this.name = name;
	}
	
	this(int id, string name, PrototypeArg nextArg) {
		super(id, nextArg);
		this.name = name;
	}
}

class Function: ASTNode {
	public:
	
	Prototype prototype() {
		return cast(Prototype) left;
	}
	
	Expression functionBody() {
		return cast(Expression) right;
	}
	
	this(int id, Prototype prototype, Expression functionBody) {
		super(id, prototype, functionBody);
	}
}

class Extern: ASTNode {
	public:
	
	Prototype prototype() {
		return cast(Prototype) left;
	}
	
	this(int id, Prototype prototype) {
		super(id, prototype);
	}
}

ASTNode[] nodes;
Stack!(Statement) statements;
int currentId;

int addNode(ASTNode node, bool isStatement = false) {
	nodes.length = cast(int) fmax(nodes.length, node.id + 1);
	nodes[node.id] = node;
	
	if(isStatement) {
		Statement statementNode = new Statement(nextId(), node);
		writefln("Creating statement %d", statementNode.id);
		if(statements.length > 0) {
			statements.peek().nextStatement = statementNode;
		}
		statements.push(statementNode);
	}
	
	return node.id;
}

string getValue(int identifier) {
	return (cast(Identifier) nodes[identifier]).name;
}

int nextId() {
	return currentId++;
}

extern (C) {
	
	int ast_number(double val) {
		return addNode(new Number(nextId(), val));
	}
	
	int ast_binary_expression(char operation, int lhIndex, int rhIndex) {
		return addNode(new BinaryExpression(nextId(), operation, 
			cast(Expression) nodes[lhIndex], 
			cast(Expression) nodes[rhIndex]));
	}
	
	int ast_variable(int identifier) {
		return addNode(new Variable(nextId(), (cast(Identifier) nodes[identifier]).name));
	}
	
	int ast_identifier(char *name) {
		return addNode(new Identifier(nextId(), toString(name)));
	}

	int ast_call(int identifier, int args) {
		if(args == -1) {
			return addNode(new Call(nextId(), getValue(identifier)));
		} else {
			return addNode(new Call(nextId(), getValue(identifier), cast(CallArg) nodes[args]));
		}
	}
	
	int ast_call_arg(int value, int nextArg) {
		if(nextArg == -1) {
			return addNode(new CallArg(nextId(), cast(Expression) nodes[value]));
		} else {
			return addNode(new CallArg(nextId(), cast(Expression) nodes[value], cast(CallArg) nodes[nextArg]));
		}
	}
	
	int ast_prototype(int identifier, int args) {
		if(args == -1) {
			return addNode(new Prototype(nextId(), getValue(identifier)));
		} else {
			return addNode(new Prototype(nextId(), getValue(identifier), cast(PrototypeArg) nodes[args]));
		}
	}
	
	int ast_prototype_arg(int identifier, int nextArg) {
		if(nextArg == -1) {
			return addNode(new PrototypeArg(nextId(), getValue(identifier)));
		} else {
			return addNode(new PrototypeArg(nextId(), getValue(identifier), cast(PrototypeArg) nodes[nextArg]));
		}
	}
	
	int ast_function(int prototype, int expression) {
		return addNode(new Function(nextId(), cast(Prototype) nodes[prototype], cast(Expression) nodes[expression]), true);
	}
	
	int ast_extern(int prototype) {
		return addNode(new Extern(nextId(), cast(Prototype) nodes[prototype]), true);
	}
}
