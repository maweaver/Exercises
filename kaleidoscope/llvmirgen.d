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

extern(C) {
	LLVMModuleRef LLVMModuleCreateWithName(char *);
	void LLVMDumpModule(LLVMModuleRef);
	
	LLVMTypeRef LLVMDoubleType();
	LLVMTypeRef LLVMFunctionType(LLVMTypeRef, LLVMTypeRef *, uint, int);
	
	LLVMBuilderRef LLVMCreateBuilder();
	void LLVMPositionBuilderAtEnd(LLVMBuilderRef, LLVMBasicBlockRef);
	LLVMValueRef LLVMBuildAdd(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildSub(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildMul(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildFDiv(LLVMBuilderRef, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildCall(LLVMBuilderRef, LLVMValueRef, LLVMValueRef*, uint, char *);
	
	LLVMValueRef LLVMConstReal(LLVMTypeRef, double);
	LLVMValueRef LLVMAddFunction(LLVMModuleRef, char *, LLVMTypeRef);
	LLVMValueRef LLVMGetParam(LLVMValueRef, uint);
	LLVMValueRef LLVMGetNamedFunction(LLVMModuleRef, char *);
	LLVMBasicBlockRef LLVMAppendBasicBlock(LLVMValueRef, char *);
	LLVMBasicBlockRef LLVMValueAsBasicBlock(LLVMValueRef);
	LLVMValueRef LLVMBuildRet(LLVMBuilderRef, LLVMValueRef);
	void LLVMSetLinkage(LLVMValueRef, int);
	
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
	
	LLVMModuleRef generateModule(string name, Statement root) {
		moduleRef = LLVMModuleCreateWithName(toStringz(name));
		builderRef = LLVMCreateBuilder();
		doubleType = LLVMDoubleType();
		expressions = new Stack!(LLVMValueRef)();
		
		root.accept(TraversalOrder.preorder, this);
		
		LLVMDumpModule(moduleRef);
		return moduleRef;
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
			writefln("Looking for 2 args from %d expressions", expressions.length);
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
			writefln("Looking for %d args from %d expressions", callArgs.length, expressions.length);
			for(int i = callArgs.length - 1; i >= 0; i--) {
				args[i] = expressions.pop();
			}
			if(args.length > 0) {
				expressions.push(LLVMBuildCall(builderRef, fn, &args[0], args.length, "call"));
			} else {
				expressions.push(LLVMBuildCall(builderRef, fn, null, 0, "call"));
			}
		}
	}
}
