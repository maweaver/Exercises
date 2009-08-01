import ast;
import stack;

import std.stdio;
import std.string;

typedef void *LLVMModuleRef;
typedef void *LLVMValueRef;
typedef void *LLVMBuilderRef;
typedef void *LLVMTypeRef;
typedef void *LLVMBasicBlockRef;

int LLVMExternalLinkage = 0;
int LLVMInternalLinkage = 4;

extern(C) {
	LLVMModuleRef LLVMModuleCreateWithName(char *);
	void LLVMDumpModule(LLVMModuleRef);
	
	LLVMTypeRef LLVMArrayType(LLVMTypeRef, uint);
	LLVMTypeRef LLVMInt8Type();
	LLVMTypeRef LLVMInt32Type();
	LLVMTypeRef LLVMInt64Type();
	LLVMTypeRef LLVMDoubleType();
	LLVMTypeRef LLVMFunctionType(LLVMTypeRef, LLVMTypeRef *, uint, int);
	LLVMTypeRef LLVMPointerType(LLVMTypeRef, uint);
	LLVMTypeRef LLVMTypeOf(LLVMValueRef);
	
	LLVMBuilderRef LLVMCreateBuilder();
	void LLVMPositionBuilderAtEnd(LLVMBuilderRef, LLVMBasicBlockRef);
	LLVMValueRef LLVMBuildAdd(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildSub(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildMul(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildFDiv(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildCall(LLVMBuilderRef, LLVMValueRef, LLVMValueRef*, uint, char *);
	LLVMValueRef LLVMBuildGEP(LLVMBuilderRef, LLVMValueRef, LLVMValueRef*, uint, char *);
	LLVMValueRef LLVMBuildLoad(LLVMBuilderRef, LLVMValueRef, char *);
	
	LLVMValueRef LLVMAddGlobal(LLVMModuleRef, LLVMTypeRef, char *);
	void LLVMSetInitializer(LLVMValueRef, LLVMValueRef);
	void LLVMSetGlobalConstant(LLVMValueRef, int);
	
	LLVMValueRef LLVMConstArray(LLVMTypeRef, LLVMValueRef *, uint);
	LLVMValueRef LLVMConstInt(LLVMTypeRef, ulong, int);
	LLVMValueRef LLVMConstReal(LLVMTypeRef, double);
	LLVMValueRef LLVMConstString(char *, uint, int);
	LLVMValueRef LLVMAddFunction(LLVMModuleRef, char *, LLVMTypeRef);
	LLVMValueRef LLVMGetParam(LLVMValueRef, uint);
	LLVMValueRef LLVMGetNamedFunction(LLVMModuleRef, char *);
	LLVMBasicBlockRef LLVMAppendBasicBlock(LLVMValueRef, char *);
	LLVMBasicBlockRef LLVMValueAsBasicBlock(LLVMValueRef);
	LLVMValueRef LLVMBuildRet(LLVMBuilderRef, LLVMValueRef);
	void LLVMSetLinkage(LLVMValueRef, int);
	
	int LLVMWriteBitcodeToFile(LLVMModuleRef, char *);
	
	void LLVMDisposeMessage(char *);
}

enum FunctionType {
	defined,
	external
}

struct FunctionContext {
	FunctionType type;
	LLVMValueRef fn;
	LLVMValueRef[string] params;
	LLVMBasicBlockRef block;
}

class LlvmIrGen: ASTNodeVisitor {
	
	private:
	
	LLVMModuleRef moduleRef;
	LLVMBuilderRef builderRef;
	LLVMTypeRef doubleType;
	LLVMTypeRef intType;
	LLVMTypeRef charType;
	LLVMTypeRef charPtrType;
	LLVMTypeRef charPtrPtrType;
	
	LLVMValueRef printf;
	LLVMValueRef printfFormat;

	FunctionContext fnContext;
	Stack!(LLVMValueRef) expressions;
	
	LLVMTypeRef getFunctionType(int numParams) {
		LLVMTypeRef[] params;
		params.length = numParams;
		for(int i = 0; i < numParams; i++) {
			params[i] = doubleType;
		}
		return LLVMFunctionType(doubleType, cast(LLVMTypeRef*) params, numParams, 0);
	}
	
	void resetFunctionContext(FunctionType type) {
		fnContext.type = type;
		fnContext.fn = null;
		foreach(key; fnContext.params.keys) {
			fnContext.params.remove(key);
		}
		fnContext.block = null;
	}
	
	public:
	
	void outputModule(string name, string filename, Statement root) {
		moduleRef = LLVMModuleCreateWithName(toStringz(name));
		builderRef = LLVMCreateBuilder();
		doubleType = LLVMDoubleType();
		intType = LLVMInt32Type();
		charType = LLVMInt8Type();
		charPtrType = LLVMPointerType(charType, 0);
		charPtrPtrType = LLVMPointerType(charPtrType, 0);
		expressions = new Stack!(LLVMValueRef)();

		LLVMValueRef[4] formatChars;
		formatChars[0] = LLVMConstInt(charType, '%', 0);
		formatChars[1] = LLVMConstInt(charType, 'f', 0);
		formatChars[2] = LLVMConstInt(charType, '\n', 0);
		formatChars[3] = LLVMConstInt(charType, '\0', 0);
		auto printfFormatVal = LLVMConstArray(charType, &formatChars[0], 4);
		printfFormat = LLVMAddGlobal(moduleRef, LLVMArrayType(charType, 4), toStringz("printfFormat"));
		LLVMSetInitializer(printfFormat, printfFormatVal);
		LLVMSetLinkage(printfFormat, LLVMInternalLinkage);
		LLVMSetGlobalConstant(printfFormat, 1);
		
		LLVMTypeRef[1] printfArgs;
		printfArgs[0] = charPtrType;
		auto printfType = LLVMFunctionType(intType, &printfArgs[0], 1, 1);
		printf = LLVMAddFunction(moduleRef, toStringz("printf"), printfType);
		LLVMSetLinkage(printf, LLVMExternalLinkage);
		
		root.accept(TraversalOrder.preorder, this);
		
		LLVMWriteBitcodeToFile(moduleRef, toStringz(filename));
	}
	
	void visit(ASTNode rootNode) {
	}
	
	void visit(Statement statement) {
	}
	
	void visit(Number number) {
		expressions.push(LLVMConstReal(doubleType, number.val));
	}
	
	void visit(Variable variable) {
		expressions.push(fnContext.params[variable.name]);
	}
	
	void visit(BinaryExpression binaryExpression) {
	}
	
	void visit(Call call) {
	}
	
	void visit(CallArg callArg) {
	}
	
	void visit(Function functionNode) {
		resetFunctionContext(FunctionType.defined);
	}
	
	void visit(Extern externNode) {
		resetFunctionContext(FunctionType.external);
	}
	
	void visit(Output outputNode) {
		resetFunctionContext(FunctionType.defined);
		LLVMTypeRef[2] mainArgTypes;
		mainArgTypes[0] = intType;
		mainArgTypes[1] = charPtrPtrType;
		auto mainType = LLVMFunctionType(intType, &mainArgTypes[0], 2, false);
		fnContext.fn = LLVMAddFunction(moduleRef, toStringz("main"), mainType);
		LLVMSetLinkage(fnContext.fn, LLVMExternalLinkage);
		fnContext.block = LLVMAppendBasicBlock(fnContext.fn, "entry");
		LLVMPositionBuilderAtEnd(builderRef, fnContext.block);
	}
	
	void visit(Prototype prototype) {
		auto preExisting = LLVMGetNamedFunction(moduleRef, toStringz(prototype.name));
		if(preExisting) {
			fnContext.fn = preExisting;
		} else {
			auto args = prototype.flatArgs;
			auto functionType = getFunctionType(args.length);
			fnContext.fn = LLVMAddFunction(moduleRef, toStringz(prototype.name), functionType);
			LLVMSetLinkage(fnContext.fn, LLVMExternalLinkage);
		}

		foreach(idx, arg; prototype.flatArgs) {
			fnContext.params[arg.name] = LLVMGetParam(fnContext.fn, idx);
		}
		
		if(fnContext.type == FunctionType.defined) {
			fnContext.block = LLVMAppendBasicBlock(fnContext.fn, "entry");
			LLVMPositionBuilderAtEnd(builderRef, fnContext.block);
		}
	}
	
	void visit(PrototypeArg prototypeArg) {
	}
	
	void unvisit(ASTNode node) {
		auto binaryExpression = cast(BinaryExpression) node;
		if(binaryExpression) {
			LLVMValueRef rhs = expressions.pop();
			LLVMValueRef lhs = expressions.pop();
		
			LLVMValueRef comboExpression = null;
			switch(binaryExpression.operation) {
				case '+': comboExpression = LLVMBuildAdd(builderRef, lhs, rhs, toStringz("addtmp")); break;
				case '-': comboExpression = LLVMBuildSub(builderRef, lhs, rhs, toStringz("subtmp")); break;
				case '*': comboExpression = LLVMBuildMul(builderRef, lhs, rhs, toStringz("multmp")); break;
				case '/': comboExpression = LLVMBuildFDiv(builderRef, lhs, rhs, toStringz("divtmp")); break;
				default: LLVMDisposeMessage(toStringz("Unexpected operator '" ~ binaryExpression.operation ~ "'")); break;
			}
		
			if(comboExpression) {
				expressions.push(comboExpression);
			}
		}
		
		auto functionNode = cast(Function) node;
		if(functionNode) {
			LLVMBuildRet(builderRef, expressions.pop());
		}
		
		auto callNode = cast(Call) node;
		if(callNode) {
			auto fn = LLVMGetNamedFunction(moduleRef, toStringz(callNode.callee));
			auto callArgs = callNode.flatArgs;
			LLVMValueRef[] args;
			args.length = callArgs.length;
			for(int i = callArgs.length - 1; i >= 0; i--) {
				args[i] = expressions.pop();
			}
			if(args.length > 0) {
				expressions.push(LLVMBuildCall(builderRef, fn, &args[0], args.length, toStringz("call")));
			} else {
				expressions.push(LLVMBuildCall(builderRef, fn, null, 0, toStringz("call")));
			}
		}
		
		auto outputNode = cast(Output) node;
		if(outputNode) {
			// auto printfArg = LLVMBuildLoad(builderRef, printfFormat, "printfArg");
			LLVMValueRef[2] gepOffsets;
			gepOffsets[0] = LLVMConstInt(LLVMInt64Type(), 0, 0);
			gepOffsets[1] = LLVMConstInt(LLVMInt64Type(), 0, 0);
			LLVMValueRef formatArg = LLVMBuildGEP(builderRef, printfFormat, &gepOffsets[0], 2, toStringz("gep"));
			LLVMValueRef[2] args;
			args[0] = formatArg;
			args[1] = expressions.pop();
			LLVMBuildCall(builderRef, printf, &args[0], 2, "printoutput");
			LLVMBuildRet(builderRef, LLVMConstInt(intType, 1, 0));
		}
	}
}
