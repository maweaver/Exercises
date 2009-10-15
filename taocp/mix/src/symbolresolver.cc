#include <iostream>
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
	if(statement) {
		if(mCurAddress != -1) {
			mCurAddress++;
			if(statement->label()) {
				mValues[statement->label()->name()] = mCurAddress;
				if(mDebug) {
					std::cerr << "Setting label " << statement->label()->name() << " to address " << mCurAddress << std::endl;
				}
			}
		}
	}

	Operation *operation = dynamic_cast<Operation *>(&node);
	if(operation && mCurAddress != -1) {
		operation->address = mCurAddress;
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
				if(mDebug) {
					std::cerr << "Deferring resolution of symbol " << equ->symbol()->name() << " due to unsatisfied dependencies" << std::endl;
				}
			}
		}
	}

	SymbolRef *symbolRef = dynamic_cast<SymbolRef *>(&node);
	if(symbolRef) {
		if(symbolRef->resolved()) {
			if(mDebug) {
				std::cerr << "Symbol " << symbolRef->symbol() << " already resolved, no action needed" << std::endl;
			}
		} else {
			if(symbolRef->symbol().length() == 2 && symbolRef->symbol()[0] >= '0' && symbolRef->symbol()[0] <= '9' && symbolRef->symbol()[1] == 'B')
			std::map<std::string, int>::iterator it = mValues.find(symbolRef->symbol());
			if(it != mValues.end()) {
				symbolRef->resolve((*it).second);
				mResolvedSymbols = true;
				if(mDebug) {
					std::cerr << "Resolving " << symbolRef->symbol() << " to value " << (*it).second << std::endl;
				}
			} else {
				mHasUnresolvedSymbols = true;
				if(mDebug) {
					std::cerr << "Reference to symbol " << symbolRef->symbol() << " could not be resolved" << std::endl;
				}
			}
		}
	}
}

void SymbolResolver::postVisit(AstNode *parent, AstNode &node)
{

}

}
