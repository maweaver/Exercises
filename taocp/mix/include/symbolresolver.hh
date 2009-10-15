#ifndef SYMBOLRESOLVER_HH_
#define SYMBOLRESOLVER_HH_

#include <map>
#include <mixal.hh>

namespace mixal {

class SymbolResolver :
public AstNodeVisitor
{
protected:

	std::map<std::string, int> mValues;

	int mCurAddress;

	bool mDebug;

	bool mResolvedSymbols;

	bool mHasUnresolvedSymbols;

public:

	SymbolResolver(bool debug);

	~SymbolResolver();

	virtual void preVisit(AstNode *parent, AstNode &node);

	virtual void visit(AstNode *parent, AstNode &node);

	virtual void postVisit(AstNode *parent, AstNode &node);

	void resolveAll(Statement *statement);

};

}


#endif /* SYMBOLRESOLVER_HH_ */
