#include <iostream>
#include <sstream>
#include <typeinfo>
#include <vector>
#include <symbolresolver.hh>

namespace mixal {

SymbolResolver::SymbolResolver(bool debug)
	: mValues(std::map<std::string, int>()), mCurAddress(-1), mDebug(debug), mResolvedSymbols(true), mHasUnresolvedSymbols(true)
{
}

SymbolResolver::~SymbolResolver()
{
}

void SymbolResolver::resolveAll(Statement *statement)
{
	std::vector<Statement *> newStatements;
	Statement *prevStatement;
	Statement *curStatement = statement;
	int conNum = 1;
	while(curStatement) {
		Operation *operation = dynamic_cast<Operation *>(curStatement->cmd());
		if(operation) {
			WExpression *wExpression = operation->wExpression();
			if(wExpression) {
				LiteralConstant *con = dynamic_cast<LiteralConstant *>(wExpression->address());
				if(con) {
					std::stringstream conLabel;
					conLabel << "_CON" << conNum++;
					newStatements.push_back(new Statement(new SymbolDecl(conLabel.str()), new Con(new WExpression(con->intValue(), NULL, NULL)), NULL));

					operation->setWExpression(new WExpression(new SymbolRef(conLabel.str()), NULL, NULL));
				}
			}
		}
		prevStatement = curStatement;
		curStatement = curStatement->next;
	}

	curStatement = prevStatement;
	for(std::vector<Statement *>::iterator newStatementsIt = newStatements.begin(); newStatementsIt != newStatements.end(); ++newStatementsIt) {
		curStatement->next = *newStatementsIt;
		curStatement = curStatement->next;
	}
	curStatement->next = NULL;

	while(mResolvedSymbols && mHasUnresolvedSymbols) {
		mResolvedSymbols = false;
		mHasUnresolvedSymbols = false;
		statement->accept(NULL, *this);

		if(mDebug) {
			std::cerr << "After this path, resolved symbols? " << mResolvedSymbols << " has unresolved symbols? " << mHasUnresolvedSymbols << std::endl;
		}
	}
}

void SymbolResolver::preVisit(AstNode *parent, AstNode &node)
{
}

void SymbolResolver::visit(AstNode *parent, AstNode &node)
{
	Orig *orig = dynamic_cast<Orig *>(&node);
	if(orig && orig->value()) {
		try {
			mCurAddress = orig->value()->value();
			mResolvedSymbols = true;
			if(mDebug) {
				std::cerr << "Changed current address to " << mCurAddress << std::endl;
			}
		} catch(const char *msg) {
			mCurAddress = -1;
			mHasUnresolvedSymbols = true;
			if(mDebug) {
				std::cerr << "Could not find current address due to an unresolved symbol" << std::endl;
			}
		}
	}

	Statement *statement = dynamic_cast<Statement *>(&node);
	if(statement && mCurAddress != -1) {
		if(statement->label()) {
			mValues[statement->label()->name()] = mCurAddress - 1;
			if(mDebug) {
				std::cerr << "Setting label " << statement->label()->name() << " to address " << mCurAddress << std::endl;
			}
		}
	}

	Con *con = dynamic_cast<Con *>(&node);
	if(con && mCurAddress != -1) {
		con->address = mCurAddress++;
	}

	Operation *operation = dynamic_cast<Operation *>(&node);
	if(operation && mCurAddress != -1) {
		operation->address = mCurAddress++;
	}

	Equ *equ = dynamic_cast<Equ *>(&node);
	if(equ && equ->symbol() && equ->value()) {
		if(mValues.find(equ->symbol()->name()) == mValues.end()) {
			try {
				mValues[equ->symbol()->name()] = equ->value()->value();
				mResolvedSymbols = true;
				if(mDebug) {
					std::cerr << "Set symbol " << equ->symbol()->name() << " to value " << equ->value()->value() << std::endl;
				}
			} catch(const char *msg) {
				mHasUnresolvedSymbols = true;
				mValues.erase(equ->symbol()->name());
				if(mDebug) {
					std::cerr << "Deferring resolution of symbol " << equ->symbol()->name() << " due to unsatisfied dependencies" << std::endl;
				}
			}
		}
	}

	SymbolRef *symbolRef = dynamic_cast<SymbolRef *>(&node);
	if(symbolRef && !symbolRef->resolved()) {
		std::string symbolName = symbolRef->symbol();
		std::string lookupName = symbolName;
		int symbolOffset = 0;

		if(symbolName.length() == 2 &&
				symbolName[0] >= '0' && symbolName[0] <= '9' &&
				symbolName[1] == 'B' || symbolName[1] == 'F') {

			symbolOffset = symbolName[1] == 'B' ? -1 : 1;
			lookupName[1] = 'H';
		}

		std::map<std::string, int>::iterator it = mValues.find(lookupName);
		if(it != mValues.end()) {
			symbolRef->resolve((*it).second + symbolOffset);
			mResolvedSymbols = true;
			if(mDebug) {
				std::cerr << "Resolving " << symbolName << "/" << lookupName << " to value " << ((*it).second + symbolOffset) << std::endl;
			}
		} else {
			mHasUnresolvedSymbols = true;
			if(mDebug) {
				std::cerr << "Reference to symbol " << symbolName << "/" << lookupName << " could not be resolved" << std::endl;
			}
		}
	}
}

void SymbolResolver::postVisit(AstNode *parent, AstNode &node)
{

}

}
