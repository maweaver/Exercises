#ifndef DOTVISITOR_H
#define DOTVISITOR_H

#include <iostream>
#include <mixal.hh>

namespace mixal {

class DotVisitor :
public AstNodeVisitor
{
protected:

	std::ostream& mOutput;

public:

	DotVisitor(std::ostream& output);

	~DotVisitor();

	virtual void preVisit(AstNode *parent, AstNode &node);

	virtual void visit(AstNode *parent, AstNode &node);

	virtual void postVisit(AstNode *parent, AstNode &node);

};

}

#endif
