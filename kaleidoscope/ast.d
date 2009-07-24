import std.gc;
import std.math;
import std.c.stdio;
import std.stdio;
import std.string;

interface ASTNodeVisitor {
	
	void visit(ASTRootNode rootNode);
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

class ASTNode {
	public:
	int id;
	
	this(int id) {
		this.id = id;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		visitor.unvisit(this);
	}
}

class ASTRootNode: ASTNode {
	public:
	Statement[] statements;
	
	this(int id, Statement[] statements) {
		super(id);
		this.statements = statements;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		foreach(s; statements) {
			s.visit(visitor);
		}
		visitor.unvisit(this);
	}
}

class Expression: ASTNode {
	this(int id) {
		super(id);
	}
}

class Statement: ASTNode {
	this(int id) {
		super(id);
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

	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		visitor.unvisit(this);
	}
}

class Variable: Expression {
	public:
	
	string name;
	
	this(int id, string name) {
		super(id);
		this.name = name;
	}

	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		visitor.unvisit(this);
	}
}

class BinaryExpression: Expression {
	public:
	
	char operation;
	Expression lhs;
	Expression rhs;
	
	this(int id, char operation, Expression lhs, Expression rhs) {
		super(id);
		this.operation = operation;
		this.lhs = lhs;
		this.rhs = rhs;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		lhs.visit(visitor);
		rhs.visit(visitor);
		visitor.unvisit(this);
	}
}

class Call: Expression {
	public:
	
	string callee;
	CallArg args;
	
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
		this.args = null;
	}
	
	this(int id, string callee, CallArg args) {
		super(id);
		this.callee = callee;
		this.args = args;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		foreach(arg; flatArgs) {
			arg.visit(visitor);
		}
		visitor.unvisit(this);
	}
}

class CallArg: Expression {
	public:
	
	Expression value;
	CallArg nextArg;
	
	this(int id, Expression value) {
		super(id);
		this.value = value;
		this.nextArg = null;
	}
	
	this(int id, Expression value, CallArg nextArg) {
		super(id);
		this.value = value;
		this.nextArg = nextArg;
	}	
	
	void visit(ASTNodeVisitor visitor) {
		value.visit(visitor);
	}
}

class Prototype: ASTNode {
	public:
	
	string name;
	PrototypeArg args;
	
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
		this.args = null;
	}
	
	this(int id, string name, PrototypeArg args) {
		super(id);
		this.name = name;
		this.args = args;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		foreach(arg; flatArgs) {
			arg.visit(visitor);
		}
		visitor.unvisit(this);
	}
}

class PrototypeArg: ASTNode {
	public:
	
	string name;
	PrototypeArg nextArg;
	
	this(int id, string name) {
		super(id);
		this.name = name;
		this.nextArg = null;
	}
	
	this(int id, string name, PrototypeArg nextArg) {
		super(id);
		this.name = name;
		this.nextArg = nextArg;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		visitor.unvisit(this);
	}
}

class Function: Statement {
	public:
	Prototype prototype;
	Expression functionBody;
	
	this(int id, Prototype prototype, Expression functionBody) {
		super(id);
		this.prototype = prototype;
		this.functionBody = functionBody;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		prototype.visit(visitor);
		functionBody.visit(visitor);
		visitor.unvisit(this);
	}
}

class Extern: Statement {
	public:
	Prototype prototype;
	
	this(int id, Prototype prototype) {
		super(id);
		this.prototype = prototype;
	}
	
	void visit(ASTNodeVisitor visitor) {
		visitor.visit(this);
		prototype.visit(visitor);
		visitor.unvisit(this);
	}	
}

ASTNode[] nodes;
Statement[] statements;
int currentId;

int addNode(ASTNode node) {
	nodes.length = cast(int) fmax(nodes.length, node.id + 1);
	nodes[node.id] = node;
	
	Statement statementNode = cast(Statement) node;
	if(statementNode) {
		statements.length = statements.length + 1;
		statements[statements.length - 1] = statementNode;
	}
	
	return node.id;
}

string getValue(int identifier) {
	return (cast(Identifier) nodes[identifier]).name;
}

int nextId() {
	return currentId++;
}

ASTRootNode getRootNode() {
	return new ASTRootNode(nextId(), statements);
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
		return addNode(new Function(nextId(), cast(Prototype) nodes[prototype], cast(Expression) nodes[expression]));
	}
	
	int ast_extern(int prototype) {
		return addNode(new Extern(nextId(), cast(Prototype) nodes[prototype]));
	}
}
