#include <stdio.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <vector>

#include <mixal.hh>
#include <dotvisitor.hh>
#include <symbolresolver.hh>

extern FILE* yyin;
extern int yyparse(void *);

namespace mixal {
	
Program::Program() 
{
}

Statement *Program::parse(const std::string& filename)
{
	yyin = NULL;
	try {
		yyin = fopen(filename.c_str(), "r");
		if(!yyin) {
			throw "Could not open input file";
		}

		std::vector<Statement *> statements;
		yyparse(&statements);

		if(yyin) {
			fclose(yyin);
		}

		if(debug) {
			std::ofstream output;
			output.open("raw.dot");
			DotVisitor dotVisitor(output);
			statements.back()->accept(NULL, dotVisitor);
		}

		SymbolResolver symbolResolver(debug);
		symbolResolver.resolveAll(statements.back());

		if(debug) {
			std::ofstream output;
			output.open("resolved.dot");
			DotVisitor dotVisitor(output);
			statements.back()->accept(NULL, dotVisitor);
		}

		return statements.back();
	} catch(const char *msg) {
		if(yyin) {
			fclose(yyin);
		}
		throw msg;
	}
}

AstNode::AstNode() 
{
}

void AstNode::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	visitor.visit(parent, *this);
	visitor.postVisit(parent, *this);
}

Alf::Alf(std::string str)
	: mStr(str), address(-1)
{
}

std::string Alf::str() const
{
	return mStr;
}

IntValue::IntValue() 
{
}

Constant::Constant(const int value) 
: mValue(value)
{
}

int Constant::value() const
{
	return mValue;
}

Self::Self() 
{
}

int Self::value() const
{
	return 0;
}

SymbolRef::SymbolRef(const std::string& symbol) 
: mSymbol(symbol), mResolved(false)
{
}

std::string SymbolRef::symbol() const
{
	return mSymbol;
}

bool SymbolRef::resolved() const
{
	return mResolved;
}

int SymbolRef::value() const
{
	if(mResolved) {
		return mValue;
	} else {
		throw "Attempted to access unresolved symbol";
	}
}

void SymbolRef::resolve(int value)
{
	mValue = value;
	mResolved = true;
}

SymbolDecl::SymbolDecl(const std::string& name)
: mName(name)
{
}

std::string SymbolDecl::name() const
{
	return mName;
}

BinaryExpression::BinaryExpression(IntValue *left, IntValue *right)
: mLeft(left), mRight(right)
{
}

void BinaryExpression::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	if(mLeft) {
		mLeft->accept(this, visitor);
	}
	visitor.visit(parent, *this);
	if(mRight) {
		mRight->accept(this, visitor);
	}
	visitor.postVisit(parent, *this);
}

AdditionExpression::AdditionExpression(IntValue *left, IntValue *right)
: BinaryExpression(left, right)
{
}

int AdditionExpression::value() const
{
	return mLeft->value() + mRight->value();
}

SubtractionExpression::SubtractionExpression(IntValue *left, IntValue *right)
: BinaryExpression(left, right)
{
}

int SubtractionExpression::value() const
{
	return mLeft->value() - mRight->value();
}

MultiplicationExpression::MultiplicationExpression(IntValue *left, IntValue *right)
: BinaryExpression(left, right)
{
}

int MultiplicationExpression::value() const
{
	return mLeft->value() * mRight->value();
}

DivisionExpression::DivisionExpression(IntValue *left, IntValue *right)
: BinaryExpression(left, right)
{
}

int DivisionExpression::value() const
{
	return mLeft->value() / mRight->value();
}

RemainderExpression::RemainderExpression(IntValue *left, IntValue *right)
: BinaryExpression(left, right)
{
}

int RemainderExpression::value() const
{
	return mLeft->value() % mRight->value();
}

UnaryExpression::UnaryExpression(IntValue *value)
: mValue(value)
{
}

void UnaryExpression::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mValue) {
		mValue->accept(this, visitor);
	}

	visitor.visit(parent, *this);
	visitor.postVisit(parent, *this);
}

NegationExpression::NegationExpression(IntValue *value)
: UnaryExpression(value)
{
}

int NegationExpression::value() const
{
	return -mValue->value();
}

BitRange::BitRange(IntValue *start)
	: mStart(start), mEnd(start)
{
}

BitRange::BitRange(IntValue *start, IntValue *end)
	: mStart(start), mEnd(end)
{
}

IntValue *BitRange::start() const
{
	return mStart;
}

IntValue *BitRange::end() const
{
	return mEnd;
}

void BitRange::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mStart) {
		mStart->accept(this, visitor);
	}

	visitor.visit(parent, *this);

	if(mEnd) {
		mEnd->accept(this, visitor);
	}

	visitor.postVisit(parent, *this);
}

Opcode::Opcode(int value, std::string token)
: Constant(value), mToken(token)
{
}

std::string Opcode::token() const
{
	return mToken;
}

WExpression::WExpression(IntValue *address, IntValue *index, BitRange *range)
	: mAddress(address), mIndex(index), mRange(range)
{
}

void WExpression::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mAddress) {
		mAddress->accept(this, visitor);
	}

	visitor.visit(parent, *this);

	if(mIndex) {
		mIndex->accept(this, visitor);
	}

	if(mRange) {
		mRange->accept(this, visitor);
	}

	visitor.postVisit(parent, *this);
}

BitRange *WExpression::range() const
{
	return mRange;
}

IntValue *WExpression::index() const
{
	return mIndex;
}

IntValue *WExpression::address() const
{
	return mAddress;
}

Con::Con(WExpression *wExpression)
	: mWExpression(wExpression)
{
}

void Con::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mWExpression) {
		mWExpression->accept(this, visitor);
	}

	visitor.visit(parent, *this);


	visitor.postVisit(parent, *this);
}

WExpression *Con::wExpression() const
{
	return mWExpression;
}

End::End(WExpression *wExpression)
	: mWExpression(wExpression)
{
}

WExpression *End::wExpression() const
{
	return mWExpression;
}

void End::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mWExpression) {
		mWExpression->accept(this, visitor);
	}

	visitor.visit(parent, *this);


	visitor.postVisit(parent, *this);
}

Operation::Operation(Opcode *opcode, WExpression *wExpression)
	: mOpcode(opcode), mWExpression(wExpression), address(-1)
{
}

void Operation::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);

	if(mWExpression) {
		mWExpression->accept(this, visitor);
	}

	visitor.visit(parent, *this);

	visitor.postVisit(parent, *this);
}

Opcode *Operation::opcode() const
{
	return mOpcode;
}

Equ::Equ(SymbolDecl *symbol, IntValue *value)
	: mSymbol(symbol), mValue(value)
{
}

const SymbolDecl *Equ::symbol() const
{
	return mSymbol;
}

const IntValue *Equ::value() const
{
	return mValue;
}

void Equ::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	if(mSymbol) {
		mSymbol->accept(this, visitor);
	}
	visitor.visit(parent, *this);
	if(mValue) {
		mValue->accept(this, visitor);
	}
	visitor.postVisit(parent, *this);
}

Orig::Orig(IntValue *value)
	: mValue(value)
{
}

void Orig::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	if(mValue) {
		mValue->accept(this, visitor);
	}
	visitor.visit(parent, *this);
	visitor.postVisit(parent, *this);
}

IntValue *Orig::value() const
{
	return mValue;
}

LiteralConstant::LiteralConstant(IntValue *value)
	: mValue(value)
{
}

IntValue *LiteralConstant::value() const
{
	return mValue;
}

void LiteralConstant::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	if(mValue) {
		mValue->accept(this, visitor);
	}
	visitor.visit(parent, *this);
	visitor.postVisit(parent, *this);
}

Statement::Statement(const SymbolDecl *label, AstNode *cmd, Statement *next)
	: mLabel(label), mCmd(cmd), mNext(next)
{
}

void Statement::accept(AstNode *parent, AstNodeVisitor &visitor)
{
	visitor.preVisit(parent, *this);
	if(mCmd) {
		mCmd->accept(this, visitor);
	}
	visitor.visit(parent, *this);
	if(mNext) {
		mNext->accept(this, visitor);
	}
	visitor.postVisit(parent, *this);
}

const SymbolDecl *Statement::label() const
{
	return mLabel;
}

const AstNode *Statement::cmd() const
{
	return mCmd;
}

const Statement *Statement::next() const
{
	return mNext;
}

}

void yyerror(char const *msg) {
	fprintf(stderr, "Error: %s\n", msg);
}
