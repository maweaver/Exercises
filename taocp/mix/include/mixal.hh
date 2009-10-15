#ifndef MIXAL_H
#define MIXAL_H

#include <string>

namespace mixal {

class AstNode;

/*!
 *  \brief Visitor for traversing an AST tree
 */
class AstNodeVisitor
{
public:

	/*!
	 *  \brief Callback method for pre-order traversal
	 */
	virtual void preVisit(AstNode *parent, AstNode &node) = 0;

	/*!
	 *  \brief Callback method for in-order traversal
	 */
	virtual void visit(AstNode *parent, AstNode &node) = 0;

	/*!
	 *  \brief Callback method for post-order traversal
	 */
	virtual void postVisit(AstNode *parent, AstNode &node) = 0;
};

/*!
 *  Base class for all nodes in the abstract syntax tree
 */
class AstNode
{
public:

	/*!
	 *  \brief Default constructor
	 */
	AstNode();

	/*!
	 *  \brief Accepts a visitor for tree traversal
	 */
	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);

};

class Alf :
public AstNode
{
protected:
	std::string mStr;

public:

	Alf(std::string str);

	std::string str() const;
};

/*!
 *  Base class for nodes in the abstract syntax tree which simplify down to an integer value at
 *  compile time.
 */
class IntValue : public AstNode
{
public:

	/*!
	 *  \brief Default constructor
	 */
	IntValue();
		
	/*!
	 *  Abstract method to calculate the value of this node
	 */
	virtual int value() const = 0;
};

/*!
 *  A constant value
 */
class Constant :
public IntValue
{
protected:

	/*!
	 *  Value of the constant
	 */
	int mValue;
		
public:

	/*!
	 *  Constructor.
	 */
	Constant(const int val);
		
	virtual int value() const;
};

/*!
 *  \brief A reference to the current operation memory location
 */
class Self :
public IntValue
{
public:

	/*!
	 *  \brief Constructor
	 */
	Self();

	virtual int value() const;
};

/*!
 *  \brief A reference to a symbol defined elsewhere
 */
class SymbolRef :
public IntValue
{
protected:
	bool mResolved;

	int mValue;

	/*!
	 *  \brief  Name of the symbol
	 */
	std::string mSymbol;
		
public:
		
	/*!
	 *  \brief Constructor
	 */
	SymbolRef(const std::string& symbol);

	/*!
	 *  \brief Name of the symbol
	 */
	std::string symbol() const;

	bool resolved() const;

	int value() const;

	void resolve(int value);
};

/*!
 *  \brief A symbol declaration.
 *
 *  Just a name; values are bound at a higher level
 */
class SymbolDecl :
public AstNode
{
	
protected:
	std::string mName;
		
public:

	/*!
	 *  \brief Constructor.
	 *
	 *  \param   name  Name of the symbol
	 */
	SymbolDecl(const std::string& name);

	/*!
	 *  \brief Name of the symbol
	 */
	std::string name() const;
};

/*!
 *  \brief  An integer created by combining two other ints
 */
class BinaryExpression :
public IntValue
{
protected:
		
	IntValue *mLeft;    /*!< Left value of combination  */
	IntValue *mRight;   /*!< Right value of combination */
		
public:
		
	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	BinaryExpression(IntValue *left, IntValue *right);

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 * \brief Addition
 */
class AdditionExpression :
public BinaryExpression
{
public:

	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	AdditionExpression(IntValue *left, IntValue *right);

	virtual int value() const;
};

/*!
 * \brief Subtraction
 */
class SubtractionExpression :
public BinaryExpression
{
public:

	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	SubtractionExpression(IntValue *left, IntValue *right);

	virtual int value() const;
};

/*!
 * \brief Multiplication
 */
class MultiplicationExpression :
public BinaryExpression
{
public:

	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	MultiplicationExpression(IntValue *left, IntValue *right);

	virtual int value() const;
};

/*!
 * \brief Division
 */
class DivisionExpression :
public BinaryExpression
{
public:

	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	DivisionExpression(IntValue *left, IntValue *right);

	virtual int value() const;
};

/*!
 * \brief Remainder
 */
class RemainderExpression :
public BinaryExpression
{
public:

	/*!
	 *  Constructor.
	 *
	 *  \param  left  Left side of the expression
	 *  \param  right Right side of the expression
	 */
	RemainderExpression(IntValue *left, IntValue *right);

	virtual int value() const;
};



/*!
 *  \brief Unary modification of an expression
 */
class UnaryExpression :
public IntValue
{
protected:
		
	/*!
	 *  \brief Value to be operated on
	 */
	IntValue *mValue;
		
public:
		
	/*!
	 *  \brief Constructor
	 *
	 *  \param   value   Value to be modified
	 */
	UnaryExpression(IntValue *value);

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 *  \brief   Negates an expression
 */
class NegationExpression :
public UnaryExpression
{
public:

	/*!
	 *  \brief Constructor
	 */
	NegationExpression(IntValue *value);

	virtual int value() const;
};
	
class BitRange :
public AstNode
{
protected:
	IntValue *mStart;
	IntValue *mEnd;

public:

	BitRange(IntValue *start, IntValue *end);

	BitRange(IntValue *range);

	IntValue *start() const;

	IntValue *end() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

class Opcode
: public Constant
{
protected:
	std::string mToken;

public:
	Opcode(int value, std::string token);

	std::string token() const;
};

class WExpression :
public AstNode
{
protected:
	BitRange *mRange;

	IntValue *mIndex;

	IntValue *mAddress;

public:

	/*!
	 *  \brief Constructor
	 */
	WExpression(IntValue *address, IntValue *index, BitRange *range);

	BitRange *range() const;

	IntValue *index() const;

	IntValue *address() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

class Con
: public AstNode
{
protected:
	WExpression *mWExpression;

public:
	Con(WExpression *wExpression);

	WExpression *wExpression() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

class End
: public AstNode
{
protected:
	WExpression *mWExpression;

public:
	End(WExpression *wExpression);

	WExpression *wExpression() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 *  \brief A mix operation
 */
class Operation :
public AstNode
{
protected:
	Opcode *mOpcode;

	WExpression *mWExpression;

public:

	/*!
	 *  \brief Constructor
	 */
	Operation(Opcode *opcode, WExpression *wExpression);

	Opcode *opcode() const;

	WExpression *wExpression() const;

	int address;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);

};


/*!
 *  \brief A mix statement.
 *
 *  Generally corresponds to a mixal line.
 */
class Statement :
public AstNode
{
protected:

	/*!
	 *  \brief Label for this statement
	 */
	const SymbolDecl *mLabel;

	/*!
	 *  \brief Command to perform
	 */
	AstNode *mCmd;

	/*!
	 *  \brief Next statement
	 */
	Statement *mNext;

public:

	/*!
	 *  \brief Constructor
	 *
	 *  \param    next  Next statement in the file
	 */
	Statement(const SymbolDecl *label, AstNode *cmd, Statement *next);

	/*!
	 *  \brief Label for this statement
	 */
	const SymbolDecl *label() const;

	/*!
	 *  \brief Command to perform
	 */
	const AstNode *cmd() const;

	/*!
	 *  \brief Next statement
	 */
	const Statement *next() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 *  \brief EQU command
 *
 *  Preprocessor command to create a constant equality
 */
class Equ :
public AstNode
{
private:
	SymbolDecl *mSymbol;
	IntValue *mValue;

public:

	/*!
	 *  Constructor
	 *
	 *  \param   name   Name of the equality
	 *  \param   value  Value it is being set to
	 */
	Equ(SymbolDecl *name, IntValue *value);

	/*!
	 *  \brief Returns the name of the symbol
	 */
	const SymbolDecl *symbol() const;

	/*!
	 *   \brief Value of the symbol
	 */
	const IntValue *value() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 *  \brief ORIG instruction
 *
 *  Changes the originating location for future instructions
 */
class Orig :
public AstNode
{
private:
	IntValue *mValue;

public:
	Orig(IntValue *value);

	IntValue *value() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};
	
class LiteralConstant :
public AstNode
{
protected:
	IntValue *mValue;

public:
	LiteralConstant(IntValue *value);

	IntValue *value() const;

	virtual void accept(AstNode *parent, AstNodeVisitor& visitor);
};

/*!
 *  \brief Program parser
 *
 *  Global state for parsing a program.
 */
class Program
{
protected:

	/*!
	 *  \brief First statement
	 *  Statements are chained together
	 */
	Statement *mRootStatement;

public:

	/*!
	 *  Default constructor.
	 */
	Program();

	/*!
	 *  If set to true, debugging information is spat out to stderr
	 */
	bool debug;

	/*!
	 *  Parses a file.  Throws an exception if an error is encountered.
	 *
	 *  \param   filename   Name of the file to be parsed
	 */
	void parse(const std::string& filename);
};

}

#endif

