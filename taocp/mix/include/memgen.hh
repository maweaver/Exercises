#ifndef MEMGEN_H
#define MEMGEN_H

#include <vector>

#include <mixal.hh>

namespace mixal {

class MemGen :
public AstNodeVisitor
{
protected:
	bool mDebug;

	std::vector<int> mMemory;

public:

	MemGen(bool debug);

	std::vector<int> memory(Statement *statements);

	virtual void preVisit(AstNode *parent, AstNode &node);

	virtual void visit(AstNode *parent, AstNode &node);

	virtual void postVisit(AstNode *parent, AstNode &node);
};

}

#endif
