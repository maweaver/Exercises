import std.gc;
import std.c.stdio;
import std.stdio;
import std.string;

class Expression {
	string toString(int level, bool left) {
		if(level > 0) {
			auto bars = repeat("│ ", level - 1);
			if(left) {
				return "  " ~ bars ~ "├─";
			} else {
				return "  " ~ bars ~ "└─";
			}
		} else {
			return "";
		}
	}
}

class Identifier : Expression {
	
	public:
	
	string name;
	
	this(string name) {
		this.name = name;
	}
}

class Number : Expression {
	public:
	
	double val;

	this(double val) {
		this.val = val;
	}
	
	string toString(int level, bool left) {
		return super.toString(level, left) ~ "NUM: " ~ std.string.toString(this.val) ~ "\n";
	}
}

class Variable : Expression {
	public:
	
	string name;
	
	this(string name) {
		this.name = name;
	}
	
	string toString(int level, bool left) {
		return super.toString(level, left) ~ "VAR: " ~ name ~ "\n";
	}
}

class BinaryExpression : Expression {
	public:
	
	char operation;
	Expression lhs;
	Expression rhs;
	
	this(char operation, Expression lhs, Expression rhs) {
		this.operation = operation;
		this.lhs = lhs;
		this.rhs = rhs;
	}
	
	string toString(int level, bool left) {
		return super.toString(level, left) ~ "BIN: " ~ operation ~ "\n" ~
			lhs.toString(level + 1, true) ~ rhs.toString(level + 1, false);
	}
}

class Call: Expression {
	public:
	
	string callee;
	Expression args;
	
	this(string callee) {
		this.callee = callee;
		this.args = null;
	}
	
	this(string callee, Expression args) {
		this.callee = callee;
		this.args = args;
	}
	
	string toString(int level, bool left) {
		auto thisStr = super.toString(level, left) ~ "FN: " ~ callee ~ "\n";
		if(args !is null) {
			return thisStr ~ args.toString(level + 1, false);
		} else {
			return thisStr;
		}
	}
}

class CallArg: Expression {
	public:
	
	Expression value;
	Expression nextArg;
	
	this(Expression value) {
		this.value = value;
		this.nextArg = null;
	}
	
	this(Expression value, Expression nextArg) {
		this.value = value;
		this.nextArg = nextArg;
	}
	
	string toString(int level, bool left) {
		if(nextArg !is null) {
			return super.toString(level, left) ~ "ARG: \n" ~ 
			value.toString(level + 1, false) ~ nextArg.toString(level + 1, true);
		} else {
			return super.toString(level, left) ~ "ARG: \n" ~
			value.toString(level + 1, false);
		}
	}
	
}

class Prototype: Expression {
	public:
	string name;
	string[] args;
}

class Function: Expression {
	public:
	Prototype prototype;
	Expression[] functionBody;
}

Expression[] nodes;
Expression[] statements;

int addNode(Expression node, bool isStatement = false) {
	// writefln(node.toString(0, false));
	nodes.length = nodes.length + 1;
	nodes[nodes.length - 1] = node;
	
	if(isStatement) {
		statements.length = statements.length + 1;
		statements[statements.length - 1] = node;
	}
	
	return nodes.length - 1;
}

extern (C) {
	
	int ast_number(double val) {
		return addNode(new Number(val));
	}
	
	int ast_binary_expression(char operation, int lhIndex, int rhIndex) {
		return addNode(new BinaryExpression(operation, nodes[lhIndex], nodes[rhIndex]), true);
	}
	
	int ast_variable(int identifier) {
		return addNode(new Variable((cast(Identifier) nodes[identifier]).name));
	}
	
	int ast_call(int identifier, int args) {
		if(args == -1) {
			return addNode(new Call((cast(Identifier) nodes[identifier]).name), true);
		} else {
			return addNode(new Call((cast(Identifier) nodes[identifier]).name, nodes[args]), true);
		}
	}
	
	int ast_call_arg(int value, int nextArg) {
		if(nextArg == -1) {
			return addNode(new CallArg(nodes[value]));
		} else {
			return addNode(new CallArg(nodes[value], nodes[nextArg]));
		}
	}
	
	int ast_identifier(char *name) {
		return addNode(new Identifier(toString(name)));
	}
}
