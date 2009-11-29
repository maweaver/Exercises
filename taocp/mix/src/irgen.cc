#include <fstream>
#include <iostream>

#include <irgen.hh>
#include <memgen.hh>
#include <parser.tab.hh>

extern "C" {
#include <mixstdlib.h>
}

#include <llvm/Constants.h>
#include <llvm/DerivedTypes.h>
#include <llvm/Function.h>
#include <llvm/Module.h>
#include <llvm/Type.h>
#include <llvm/Support/IRBuilder.h>
#include <llvm/Bitcode/ReaderWriter.h>

namespace mixal {

IrGen::IrGen(bool debug, const std::string& name)
	: mDebug(debug), mName(name)
{
}

IrGen::~IrGen() {
	delete mModule;
}

void IrGen::generate(Statement *statements) {
	mByteType = llvm::IntegerType::get(6);
	mDoubleByteType = llvm::IntegerType::get(13);
	mWordType = llvm::IntegerType::get(31);
	mCIntType = llvm::IntegerType::get(32);

	mModule = new llvm::Module(mName);

	MemGen memgen = new MemGen(mDebug);
	std::vector<int> initialMemory = memgen.memory(statements);
	std::vector<llvm::Constant *> initialMemoryConsts;
	for(std::vector<int>::iterator it = initialMemory.begin();
		it != initialMemory.end(); ++it) {
		initialMemoryConsts.push_back(llvm::ConstantInt::get(mWordType, mix_int_to_word(*it), true));
	}

	llvm::ArrayType *mainMemoryType = llvm::ArrayType::get(mWordType, 4000);
	
	mMainMemory = new llvm::GlobalVariable(mainMemoryType, false, 
										   llvm::GlobalValue::InternalLinkage, 
										   llvm::ConstantArray::get(mainMemoryType, initialMemoryConsts), 
										   "main_memory", mModule);

	std::vector<const llvm::Type*> iocArgs;
	iocArgs.push_back(mCIntType);
	iocArgs.push_back(mCIntType);
	llvm::FunctionType *iocType = llvm::FunctionType::get(llvm::Type::VoidTy, iocArgs, false);
	mIoc = llvm::Function::Create(iocType, llvm::GlobalValue::ExternalLinkage, "mix_ioc", mModule);

	std::vector<const llvm::Type*> outArgs;
	outArgs.push_back(mCIntType);
	outArgs.push_back(llvm::PointerType::get(mCIntType, 0));
	outArgs.push_back(mCIntType);
	llvm::FunctionType *outType = llvm::FunctionType::get(llvm::Type::VoidTy, outArgs, false);
	mOut = llvm::Function::Create(outType, llvm::GlobalValue::ExternalLinkage, "mix_out", mModule);

	llvm::ArrayType *iType = llvm::ArrayType::get(mDoubleByteType, 6);

	std::vector<llvm::Constant *> initialIs;
	for(int i = 0; i < 6; i++) {
		initialIs.push_back(llvm::ConstantInt::get(mDoubleByteType, 0, true));
	}

	mIs = new llvm::GlobalVariable(iType, false, 
								   llvm::GlobalValue::InternalLinkage, 
								   llvm::ConstantArray::get(iType, initialIs),
								   "i1", mModule);

	llvm::FunctionType *simpleFnType = llvm::FunctionType::get(llvm::Type::VoidTy, std::vector<const llvm::Type*>(), false);
	llvm::Function *initFn = llvm::Function::Create(simpleFnType, llvm::GlobalValue::ExternalLinkage, "mix_init", mModule);
	mLibDestroy = llvm::Function::Create(simpleFnType, llvm::GlobalValue::ExternalLinkage, "mix_destroy", mModule);

	std::vector<const llvm::Type *> mainArgs;
	mainArgs.push_back(mCIntType);
	mainArgs.push_back(llvm::PointerType::get(llvm::PointerType::get(llvm::IntegerType::get(8), 0), 0));
	llvm::FunctionType *mainType = llvm::FunctionType::get(mCIntType, mainArgs, false);
	llvm::Function *main = llvm::Function::Create(mainType, llvm::GlobalValue::ExternalLinkage, "main", mModule);
	mBasicBlock = llvm::BasicBlock::Create("entry", main);

	mBuilder = new llvm::IRBuilder<>(mBasicBlock);
	mBuilder->CreateCall(initFn);

	statements->accept(NULL, *this);
	if(mDebug) {
		mModule->dump();
	}
}

void IrGen::preVisit(AstNode *parent, AstNode &node)
{

}

void IrGen::postVisit(AstNode *parent, AstNode &node)
{
	mixal::Operation *operation = dynamic_cast<mixal::Operation *>(&node);
	if(operation) {
		switch(operation->opcode()->value()) {
		case TOKEN_OP_HLT:
			halt();
			break;
		case TOKEN_OP_INC1:
			inci(1, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_INC2:
			inci(2, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_INC3:
			inci(3, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_INC4:
			inci(4, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_INC5:
			inci(5, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_INC6:
			inci(6, operation->wExpression()->address()->value());
			break;
		case TOKEN_OP_IOC:
			ioc(operation->wExpression()->address()->value(), operation->wExpression()->range()->start()->value());
			break;
		case TOKEN_OP_LD1:
			ldi(1, operation->wExpression());
			break;
		case TOKEN_OP_LD2:
			ldi(2, operation->wExpression());
			break;
		case TOKEN_OP_LD3:
			ldi(3, operation->wExpression());
			break;
		case TOKEN_OP_LD4:
			ldi(4, operation->wExpression());
			break;
		case TOKEN_OP_LD5:
			ldi(5, operation->wExpression());
			break;
		case TOKEN_OP_LD6:
			ldi(6, operation->wExpression());
			break;
		case TOKEN_OP_ST1:
			sti(1, operation->wExpression());
			break;
		case TOKEN_OP_ST2:
			sti(2, operation->wExpression());
			break;
		case TOKEN_OP_ST3:
			sti(3, operation->wExpression());
			break;
		case TOKEN_OP_ST4:
			sti(4, operation->wExpression());
			break;
		case TOKEN_OP_ST5:
			sti(5, operation->wExpression());
			break;
		case TOKEN_OP_ST6:
			sti(6, operation->wExpression());
			break;
		case TOKEN_OP_OUT:
			out(operation->wExpression()->range()->start()->value(), operation->wExpression()->address()->value());
			break;
		}
	}
}

void IrGen::visit(AstNode *parent, AstNode &node)
{
	
}

void IrGen::halt() 
{
	mBuilder->CreateCall(mLibDestroy);
	mBuilder->CreateRet(llvm::ConstantInt::get(mCIntType, 0, true));
}

void IrGen::inci(int i, int amount) {
	llvm::Value *num = mBuilder->CreateLoad(iRegPtr(i), "inci_load");
	llvm::Value *add = mBuilder->CreateAdd(num, llvm::ConstantInt::get(mDoubleByteType, amount, true), "inci_add");
	mBuilder->CreateStore(add, iRegPtr(i), "inci_store");
}

void IrGen::ioc(int device, int operation) 
{
	mBuilder->CreateCall2(mIoc, 
						  llvm::ConstantInt::get(mCIntType, device, true),
						  llvm::ConstantInt::get(mCIntType, operation, true));
}

void IrGen::ldi(int i, WExpression *wExpression)
{
	// Loading into the i registers have an implicit field byte range of (4:5); create a new
	// wExpression with that range
	ld(iRegPtr(i), new WExpression(wExpression->address(), wExpression->index(), new BitRange(new Constant(4), new Constant(5))));
}

void IrGen::ld(llvm::Value *dest, WExpression *wExpression)
{
	llvm::Value *src = load(wExpression);

	std::vector<llvm::Value *> destOffset;
	destOffset.push_back(llvm::ConstantInt::get(mCIntType, 0, true));

	llvm::Value *destPtr = mBuilder->CreateGEP(dest,
											   destOffset.begin(), destOffset.end(),
											   "ld_dest_ptr");

	mBuilder->CreateStore(src, destPtr, "ld_store");
}

void IrGen::out(int device, int address) {
	int blockSize = 100;
	if(device == 16 || device == 17) {
		blockSize = 16;
	} else if(device == 18) {
		blockSize = 24;
	} else if(device == 19 || device == 20) {
		blockSize = 14;
	}

	llvm::MallocInst *words = 
		mBuilder->CreateMalloc(mCIntType,
							   llvm::ConstantInt::get(mCIntType, blockSize, true),
							   "out_words");

	for(int i = 0; i < blockSize; i++) {
		std::vector<llvm::Value *> wordSrcOffset;
		wordSrcOffset.push_back(llvm::ConstantInt::get(mCIntType, 0, true));
		wordSrcOffset.push_back(llvm::ConstantInt::get(mCIntType, address + i, true));

		llvm::Value *wordSrcPtr = 
			mBuilder->CreateGEP(mMainMemory,
								wordSrcOffset.begin(), wordSrcOffset.end(),
								"out_word_src_ptr");

		std::vector<llvm::Value *> wordDestOffset;
		wordDestOffset.push_back(llvm::ConstantInt::get(mCIntType, i, true));

		llvm::Value *wordDestPtr = 
			mBuilder->CreateGEP(words,
								wordDestOffset.begin(), wordDestOffset.end(),
								"out_word_dest_ptr");
		llvm::LoadInst *loaded = mBuilder->CreateLoad(wordSrcPtr, "out_word");
		llvm::Value *cVal = mBuilder->CreateZExt(loaded, mCIntType, "out_cast_word");
		mBuilder->CreateStore(cVal, wordDestPtr, "out_store_word");
	}

	mBuilder->CreateCall3(mOut, 
						  llvm::ConstantInt::get(mCIntType, device, true),
						  words, llvm::ConstantInt::get(mCIntType, blockSize));

	mBuilder->CreateFree(words);
}

void IrGen::sti(int i, WExpression *wExpression)
{
	// Loading into the i registers have an implicit field byte range of (4:5); create a new
	// wExpression with that range
	llvm::Value *value = mBuilder->CreateLoad(iRegPtr(i), "sti_load");
	store(wExpression, value, 13);
}

llvm::Value *IrGen::iRegPtr(int i) {
	std::vector<llvm::Value *> iOffset;
	iOffset.push_back(llvm::ConstantInt::get(mCIntType, 0, true));
	iOffset.push_back(llvm::ConstantInt::get(mCIntType, i, true));

	llvm::Value *iPtr =
		mBuilder->CreateGEP(mIs,
							iOffset.begin(), iOffset.end(),
							"i_ptr");
	return iPtr;
}

llvm::Value *IrGen::load(WExpression *addr) {
	// Get the address
	llvm::Value *address = llvm::ConstantInt::get(mCIntType, addr->address()->value(), true);

	// If there is an I-part, load it and add to address
	if(addr->index()) {
		llvm::Value *iPtr = iRegPtr(addr->index()->value() - 1);						
		llvm::Value *i = mBuilder->CreateLoad(iPtr, "load_i_val");
		llvm::Value *iExt = mBuilder->CreateSExt(i, mCIntType, "load_i_ext");
		address = mBuilder->CreateAdd(address, iExt, "load_i_add");
	}

	// Get the raw byte
	std::vector<llvm::Value *> srcOffset;
	srcOffset.push_back(llvm::ConstantInt::get(mCIntType, 0, true));
	srcOffset.push_back(llvm::ConstantInt::get(mCIntType, addr->address()->value(), true));

	llvm::Value *srcPtr = 
		mBuilder->CreateGEP(mMainMemory, 
							srcOffset.begin(), srcOffset.end(),
							"load_slice_src_ptr");
	llvm::LoadInst *load = mBuilder->CreateLoad(srcPtr, "load_slice_load");

	if(addr->range()) {
		int start = addr->range()->start()->value();
		int end = addr->range()->end()->value();
		int mask = 0;
		for(int i = 0; i < (end - start + 1); i++) {
			mask = mask << 6;
			mask += 0x3F;
		}

		// Get the sign bit, then create a number with the sign to the left
		// of the result numbers
		
		llvm::Value *unshiftedSign = 
			mBuilder->CreateAnd(load, 
								llvm::ConstantInt::get(mWordType, 0x40000000, true), 
								"load_slice_unshifted_sign");
		llvm::Value *sign =
			mBuilder->CreateAShr(unshiftedSign,
								 llvm::ConstantInt::get(mWordType, 30, true),
								 "load_slice_sign");

		llvm::Value *maskedSign =
			mBuilder->CreateAnd(sign,
								llvm::ConstantInt::get(mWordType, mask, true),
								"load_slice_sign_mask");

		// Shift out bits to the right of end, clear out the bits to the left
		llvm::Value *shifted = 
			mBuilder->CreateLShr(load,
								 llvm::ConstantInt::get(mWordType, (5 - end) * 6, true),
								 "load_slice_shift_right");

		llvm::Value *cleared = 
			mBuilder->CreateAnd(shifted,
								llvm::ConstantInt::get(mWordType, mask, true),
								"load_slice_masked");
		// Replace bits to the left of start with the sign bit
		llvm::Value *res = mBuilder->CreateOr(cleared, maskedSign, "load_slice_res");

		// Cast the result
		return mBuilder->CreateTrunc(res,
									 llvm::IntegerType::get((end - start + 1) * 6 + 1),
									 "load_slice_truncated");
	} else {
		return load;
	}

}

void IrGen::store(WExpression *addr, llvm::Value *value, int numValueBits) {
	// Ok, this is a weird one.

	// First, extend the value out to a full word, filling in zeroes for all bits, but leaving the 
	// sign bit in place.  Do this by sign-extending the value, and then zeroing out all the 
	// intervening bits

	llvm::Value *signExtended = mBuilder->CreateSExt(value, mWordType, "store_sign_extend");
	int zeroMask = 0;
	for(int i = 0; i < numValueBits - 1; i++) {
		zeroMask <<= 1;
		zeroMask++;
	}
	zeroMask |= 0x40000000;
	llvm::Value *anded = mBuilder->CreateAnd(signExtended, 
											 llvm::ConstantInt::get(mWordType, zeroMask), "store_and");

	// Get the destination address
	std::vector<llvm::Value *> destOffset;
	destOffset.push_back(llvm::ConstantInt::get(mCIntType, 0, true));
	destOffset.push_back(llvm::ConstantInt::get(mCIntType, addr->address()->value(), true));

	llvm::Value *destPtr = 
		mBuilder->CreateGEP(mMainMemory, 
							destOffset.begin(), destOffset.end(),
							"store_dest_ptr");

	if(addr->range()) {
		// Now, pull in the last (end - start + 1) bytes from the *destination* bitrange from
		// the *value*

		int valueMask = 0;
		for(int i = 0; i < addr->range()->end()->value() - addr->range()->start()->value() + 1; i++) {
			valueMask <<= 6;
			valueMask += 0x3F;
		}
		llvm::Value *maskedValue = mBuilder->CreateAnd(anded, 
													   llvm::ConstantInt::get(mWordType, valueMask), 
													   "store_mask");

		// Shift them into the final position
		llvm::Value *shiftedValue = mBuilder->CreateShl(maskedValue,
														llvm::ConstantInt::get(mWordType,
																			   (6 - addr->range()->start()->value()) * 6),
														"store_shift");

		// Load the original value
		llvm::Value *destValue = mBuilder->CreateLoad(destPtr, "store_load");

		// Zero out bytes corresponding to the value
		llvm::Value *maskedDestValue = mBuilder->CreateAnd(destValue,
														   llvm::ConstantInt::get(mWordType, ~valueMask),
														   "store_load_mask");
		
		// Or the two together
		llvm::Value *finalDestValue = mBuilder->CreateOr(maskedDestValue, value);

		// Store the result
		mBuilder->CreateStore(finalDestValue, destPtr, "store_store");
	} else {
		mBuilder->CreateStore(anded, destPtr, "addr_store_unmasked");
	}
}

llvm::Module *IrGen::module() const {
	return mModule;
}

}
