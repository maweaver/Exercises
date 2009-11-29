#ifndef IRGEN_H
#define IRGEN_H

#include <mixal.hh>
#include <llvm/Module.h>
#include <llvm/Support/IRBuilder.h>

namespace mixal {

class IrGen :
public AstNodeVisitor
{
protected:
	bool mDebug;
	std::string mName;

	llvm::Module *mModule;

	llvm::IRBuilder<> *mBuilder;

	llvm::BasicBlock *mBasicBlock;

	llvm::Function *mIoc;
	llvm::Function *mOut;
	llvm::Function *mLibDestroy;

	llvm::GlobalVariable *mMainMemory;
	llvm::GlobalVariable *mIs;

	const llvm::Type *mByteType;
	const llvm::Type *mDoubleByteType;
	const llvm::Type *mWordType;
	const llvm::Type *mCIntType;

	void halt();
	void inci(int i, int amount);
	void ioc(int device, int operation);
	void ld(llvm::Value *dest, WExpression *wExpression);
	void ldi(int i, WExpression *wExpression);
	void out(int device, int address);
	void sti(int i, WExpression *wExpression);

	llvm::Value *iRegPtr(int i);
	llvm::Value *load(WExpression *addr);
	void store(WExpression *addr, llvm::Value *value, int numBits);
	
public:

	IrGen(bool debug, const std::string& name);

	~IrGen();

	void generate(Statement *statement);

	llvm::Module *module() const;

	virtual void preVisit(AstNode *parent, AstNode &node);

	virtual void visit(AstNode *parent, AstNode &node);

	virtual void postVisit(AstNode *parent, AstNode &node);
};
}

#endif
