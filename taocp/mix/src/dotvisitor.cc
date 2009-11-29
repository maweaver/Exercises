#include <iostream>
#include <typeinfo>

#include <dotvisitor.hh>

namespace mixal {

DotVisitor::DotVisitor(std::ostream& output)
	: mOutput(output)
{
	mOutput << "digraph G {" << std::endl;
}

DotVisitor::~DotVisitor()
{
	mOutput << "}\n" << std::endl;
}

void DotVisitor::preVisit(AstNode *parent, AstNode &node)
{

}

void DotVisitor::visit(AstNode *parent, AstNode &node)
{
	const std::type_info &info = typeid(node);

	Statement *stmt = dynamic_cast<Statement *>(&node);
	if(stmt != NULL) {
		mOutput << "\t\"" << stmt << "\" [shape=box, label=\"" << (stmt->label() != NULL ? stmt->label()->name() : "") << "\"];" << std::endl;
	} else {
		mOutput << "\t\"" << parent << "\" -> \"" << &node << "\";" << std::endl;

		Alf *alf = dynamic_cast<Alf *>(&node);
		if(alf) {
			mOutput << "\t\"" << alf << "\" [shape=box, label=\"" << alf->address << ":" << "ALF:" << alf->str() << "\"];" << std::endl;
		}

		Equ *equ = dynamic_cast<Equ *>(&node);
		if(equ) {
			mOutput << "\t\"" << equ << "\" [shape=box, label=EQU];" << std::endl;
		}

		SymbolDecl *symbolDecl = dynamic_cast<SymbolDecl *>(&node);
		if(symbolDecl) {
			mOutput << "\t\"" << symbolDecl << "\" [label=\"" << symbolDecl->name() << "\"];" << std::endl;
		}

		SymbolRef *symbolRef = dynamic_cast<SymbolRef *>(&node);
		if(symbolRef) {
			mOutput << "\t\"" << symbolRef << "\" [label=\"[" << symbolRef->symbol() << "]\"];" << std::endl;
		}

		Constant *constant = dynamic_cast<Constant *>(&node);
		if(constant) {
			mOutput << "\t\"" << constant << "\" [shape=box, label=\"" << constant->value() << "\"];" << std::endl;
		}

		NegationExpression *negation = dynamic_cast<NegationExpression *>(&node);
		if(negation) {
			mOutput << "\t\"" << negation << "\" [label=\"-\"];" << std::endl;
		}

		AdditionExpression *addition = dynamic_cast<AdditionExpression *>(&node);
		if(addition) {
			mOutput << "\t\"" << addition << "\" [label=\"+\"];" << std::endl;
		}

		SubtractionExpression *subtraction = dynamic_cast<SubtractionExpression *>(&node);
		if(subtraction) {
			mOutput << "\t\"" << subtraction << "\" [label=\"-\"];" << std::endl;
		}

		MultiplicationExpression *multiplication = dynamic_cast<MultiplicationExpression *>(&node);
		if(multiplication) {
			mOutput << "\t\"" << subtraction << "\" [label=\"*\"];" << std::endl;
		}

		DivisionExpression *division = dynamic_cast<DivisionExpression *>(&node);
		if(division) {
			mOutput << "\t\"" << subtraction << "\" [label=\"/\"];" << std::endl;
		}

		Orig *orig = dynamic_cast<Orig *>(&node);
		if(orig) {
			mOutput << "\t\"" << orig << "\" [shape=box, label=ORIG];" << std::endl;
		}

		Operation *operation = dynamic_cast<Operation *>(&node);
		if(operation) {
			mOutput << "\t\"" << operation << "\" [label=\"" << operation->opcode()->token() << "\"];" << std::endl;
		}

		LiteralConstant *literalConstant = dynamic_cast<LiteralConstant *>(&node);
		if(literalConstant) {
			mOutput << "\t\"" << literalConstant << "\" [label=CON];" << std::endl;
		}

		WExpression *wExpression = dynamic_cast<WExpression*>(&node);
		if(wExpression) {
			mOutput << "\t\"" << wExpression << "\" [label=W];" << std::endl;
		}

		BitRange *bitRange = dynamic_cast<BitRange *>(&node);
		if(bitRange) {
			mOutput << "\t\"" << bitRange << "\" [label=\"[:]\"];" << std::endl;
		}

		Con *con = dynamic_cast<Con *>(&node);
		if(con) {
			mOutput << "\t\"" << con << "\" [label=CON, shape=box];" << std::endl;
		}

		End *end = dynamic_cast<End *>(&node);
		if(end) {
			mOutput << "\t\"" << end << "\" [label=END, shape=box];" << std::endl;
		}
	}
}

void DotVisitor::postVisit(AstNode *parent, AstNode &node)
{

}

}
