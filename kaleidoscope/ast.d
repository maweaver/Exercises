import std.gc;
import std.math;
import std.c.stdio;
import std.stdio;
import std.string;

import stack;

class ASTNodeVisitor {

	void previsit(BinaryExpression binaryExpression) { }
	void visit(BinaryExpression binaryExpression) { }
	void postvisit(BinaryExpression binaryExpression) { }

	void previsit(BooleanExpression booleanExpression) { }
	void visit(BooleanExpression booleanExpression) { }
	void postvisit(BooleanExpression booleanExpression) { }

	void previsit(Call call) { }
	void visit(Call call) { }
	void postvisit(Call call) { }

	void previsit(CallArg callArg) { }
	void visit(CallArg callArg) { }
	void postvisit(CallArg callArg) { }

	void previsit(Extern externNode) { }
	void visit(Extern externNode) { }
	void postvisit(Extern externNode) { }

	void previsit(Function functionNode) { }
	void visit(Function functionNode) { }
	void postvisit(Function functionNode) { }

	void previsit(If ifNode) { }
	void visit(If ifNode) { }
	void postvisit(If ifNode) { }

	void previsit(Input inputNode) { }
	void visit(Input inputNode) { }
	void postvisit(Input inputNode) { }

	void previsit(Number number) { }
	void visit(Number number) { }
	void postvisit(Number number) { }

	void previsit(Output outputNode) { }
	void visit(Output outputNode) { }
	void postvisit(Output outputNode) { }

	void previsit(Prototype prototype) { }
	void visit(Prototype prototype) { }
	void postvisit(Prototype prototype) { }

	void previsit(PrototypeArg prototypeArg) { }
	void visit(PrototypeArg prototypeArg) { }
	void postvisit(PrototypeArg prototypeArg) { }

	void previsit(Statement stmt) { }
	void visit(Statement stmt) { }
	void postvisit(Statement stmt) { }

	void previsit(ThenElse thenElseNode) { }
	void visit(ThenElse thenElseNode) { }
	void postvisit(ThenElse thenElseNode) { }

	void previsit(Variable variable) { }
	void visit(Variable variable) { }
	void postvisit(Variable variable) { }

	void previsit(ASTNode node) { }
	void visit(ASTNode node) { }
	void postvisit(ASTNode node) { }
}

template Accept() {
	void accept(ASTNodeVisitor v) {
		v.previsit(this);
		if(left) {
			left.accept(v);
		}
		v.visit(this);
		if(right) {
			right.accept(v);
		}
		v.postvisit(this);
	}
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
	
	mixin Accept;
}

class Expression: ASTNode {
	this(int id, ASTNode left = null, ASTNode right = null) {
		super(id, left, right);
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

class BinaryExpression: Expression {
	public:
	
	char operation;
	
	Expression lhs() {
		return cast(Expression) left;
	}
	
	Expression rhs() {
		return cast(Expression) right;
	}
	
	this(int id, char operation, ASTNode left, ASTNode right) {
		super(id, left, right);
		this.operation = operation;
	}
	
	mixin Accept;
}

class BooleanExpression: Expression {
	public:
	
	char operation;
	
	Expression lhs() {
		return cast(Expression) left;
	}
	
	Expression rhs() {
		return cast(Expression) right;
	}
	
	this(int id, char operation, ASTNode left, ASTNode right) {
		super(id, left, right);
		this.operation = operation;
	}
	
	mixin Accept;
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
	
	this(int id, string callee, ASTNode args) {
		super(id, args);
		this.callee = callee;
	}
	
	mixin Accept;
}

class CallArg: Expression {
	public:
	
	Expression value() {
		return cast(Expression) left;
	}
	
	CallArg nextArg() {
		return cast(CallArg) right;
	}
	
	this(int id, ASTNode value) {
		super(id, value);
	}
	
	this(int id, ASTNode value, ASTNode nextArg) {
		super(id, value, nextArg);
	}
	
	mixin Accept;
}

class Extern: ASTNode {
	public:
	
	Prototype prototype() {
		return cast(Prototype) left;
	}
	
	this(int id, ASTNode prototype) {
		super(id, prototype);
	}
	
	mixin Accept;
}

class Function: ASTNode {
	public:
	
	Prototype prototype() {
		return cast(Prototype) left;
	}
	
	Expression functionBody() {
		return cast(Expression) right;
	}
	
	this(int id, ASTNode prototype, ASTNode functionBody) {
		super(id, prototype, functionBody);
	}
	
	mixin Accept;
}

class If: Expression {
	public:
	
	BooleanExpression condition() {
		return cast(BooleanExpression) left;
	}
	
	ThenElse result() {
		return cast(ThenElse) right;
	}
	
	this(int id, ASTNode condition, ASTNode result) {
		super(id, condition, result);
	}
	
	mixin Accept;
}

class Input: ASTNode {
	public:
	
	this(int id) {
		super(id);
	}
	
	mixin Accept;
}

class Number: Expression {
	public:
	
	double val;

	this(int id, double val) {
		super(id);
		this.val = val;
	}
	
	mixin Accept;
}

class Output: ASTNode {
	public:
	
	Expression expression() {
		return cast(Expression) left;
	}
	
	this(int id, ASTNode expression) {
		super(id, expression);
	}
	
	mixin Accept;
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
	
	this(int id, string name, ASTNode args) {
		super(id, args);
		this.name = name;
	}
	
	mixin Accept;
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
	
	this(int id, string name, ASTNode nextArg) {
		super(id, nextArg);
		this.name = name;
	}
	
	mixin Accept;
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
		
	this(int id, ASTNode statement, ASTNode nextStatement = null) {
		super(id, statement, nextStatement);
	}
	
	mixin Accept;
}

class ThenElse: ASTNode {
	public:
	
	this(int id, ASTNode thenNode, ASTNode elseNode) {
		super(id, thenNode, elseNode);
	}
	
	mixin Accept;
}

class Variable: Expression {
	public:
	
	string name;
	
	this(int id, string name) {
		super(id);
		this.name = name;
	}
	
	mixin Accept;
}

ASTNode[] nodes;
Stack!(Statement) statements;
int currentId;

int addNode(ASTNode node, bool isStatement = false) {
	nodes.length = cast(int) fmax(nodes.length, node.id + 1);
	nodes[node.id] = node;
	
	if(!statements) {
		statements = new Stack!(Statement)();
	}
	
	if(isStatement) {
		Statement statementNode = new Statement(nextId(), node);
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
	
	int ast_identifier(char *name) {
		return addNode(new Identifier(nextId(), toString(name)));
	}

	int ast_binary_expression(char operation, int lhIndex, int rhIndex) {
		return addNode(new BinaryExpression(nextId(), operation, nodes[lhIndex], nodes[rhIndex]));
	}
	
	int ast_boolean_expression(char operation, int left, int right) {
		return addNode(new BooleanExpression(nextId(), operation, nodes[left], nodes[right]));
	}
	
	int ast_call(int identifier, int args) {
		if(args == -1) {
			return addNode(new Call(nextId(), getValue(identifier)));
		} else {
			return addNode(new Call(nextId(), getValue(identifier), nodes[args]));
		}
	}
	
	int ast_call_arg(int value, int nextArg) {
		if(nextArg == -1) {
			return addNode(new CallArg(nextId(), nodes[value]));
		} else {
			return addNode(new CallArg(nextId(), nodes[value], nodes[nextArg]));
		}
	}
	
	int ast_extern(int prototype) {
		return addNode(new Extern(nextId(), nodes[prototype]), true);
	}
	
	int ast_function(int prototype, int expression) {
		return addNode(new Function(nextId(), nodes[prototype], nodes[expression]), true);
	}
	
	int ast_if(int booleanExpression, int thenElse) {
		return addNode(new If(nextId(), nodes[booleanExpression], nodes[thenElse]));
	}
	
	int ast_input(int expression) {
		return addNode(new Input(nextId()));
	}
	
	int ast_number(double val) {
		return addNode(new Number(nextId(), val));
	}
	
	int ast_output(int expression) {
		return addNode(new Output(nextId(), nodes[expression]), true);
	}
	
	int ast_prototype(int identifier, int args) {
		if(args == -1) {
			return addNode(new Prototype(nextId(), getValue(identifier)));
		} else {
			return addNode(new Prototype(nextId(), getValue(identifier), nodes[args]));
		}
	}
	
	int ast_prototype_arg(int identifier, int nextArg) {
		if(nextArg == -1) {
			return addNode(new PrototypeArg(nextId(), getValue(identifier)));
		} else {
			return addNode(new PrototypeArg(nextId(), getValue(identifier), nodes[nextArg]));
		}
	}
	
	int ast_then_else(int thenNode, int elseNode) {
		return addNode(new ThenElse(nextId(), nodes[thenNode], nodes[elseNode]));
	}
	
	int ast_variable(int identifier) {
		return addNode(new Variable(nextId(), (cast(Identifier) nodes[identifier]).name));
	}
}
