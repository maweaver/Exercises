import ast;
import stack;

import std.stdio;
import std.string;

typedef void *LLVMModuleRef;
typedef void *LLVMValueRef;
typedef void *LLVMBuilderRef;
typedef void *LLVMTypeRef;

int LLVMExternalLinkage = 0;

extern(C) {
	LLVMModuleRef LLVMModuleCreateWithName(char *ModuleID);
	void LLVMDumpModule(LLVMModuleRef m);
	
	LLVMTypeRef LLVMDoubleType();
	LLVMTypeRef LLVMFunctionType(LLVMTypeRef returnType, LLVMTypeRef *paramTypes, uint paramCount, int isVarArg);
	
	LLVMBuilderRef LLVMCreateBuilder();
	LLVMValueRef LLVMBuildAdd(LLVMBuilderRef b, LLVMValueRef lhs, LLVMValueRef rhs, char *msg);
	LLVMValueRef LLVMBuildSub(LLVMBuilderRef b, LLVMValueRef lhs, LLVMValueRef rhs, char *msg);
	LLVMValueRef LLVMBuildMul(LLVMBuilderRef b, LLVMValueRef lhs, LLVMValueRef rhs, char *msg);
	LLVMValueRef LLVMBuildFDiv(LLVMBuilderRef b, LLVMValueRef lhs, LLVMValueRef rhs, char *msg);
	
	LLVMValueRef LLVMConstReal(LLVMTypeRef t, double n);
	LLVMValueRef LLVMAddFunction(LLVMModuleRef m, char *name, LLVMTypeRef fType);
	void LLVMSetLinkage(LLVMValueRef Global, int Linkage);
	
	void LLVMDisposeMessage(char *message);
}

class LlvmIrGen: ASTNodeVisitor {
	
	private:
	
	LLVMModuleRef moduleRef;
	LLVMBuilderRef builderRef;
	
	LLVMTypeRef doubleType;
	Stack!(LLVMValueRef) parentValues;
	
	LLVMValueRef currentFunction;
	LLVMValueRef[string] curentFunctionParams;
	Stack!(LLVMValueRef) expressions;
	
	LLVMTypeRef getFunctionType(int numParams) {
		LLVMTypeRef[] params;
		params.length = numParams;
		for(int i = 0; i < numParams; i++) {
			params[i] = doubleType;
		}
		return LLVMFunctionType(doubleType, cast(LLVMTypeRef*) params, numParams, 0);
	}
	
	public:
	
	LLVMModuleRef generateModule(string name, Statement root) {
		moduleRef = LLVMModuleCreateWithName(toStringz(name));
		builderRef = LLVMCreateBuilder();
		doubleType = LLVMDoubleType();
		
		root.accept(TraversalOrder.postorder, this);
		
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
		// expressions.push(currentFunctionParams[variable.name]);
	}
	
	void visit(BinaryExpression binaryExpression) {
		LLVMValueRef lhs = expressions.pop();
		LLVMValueRef rhs = expressions.pop();
		
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
	
	void visit(Call call) {
	}
	
	void visit(CallArg callArg) {
	}
	
	void visit(Function functionNode) {
	}
	
	void visit(Prototype prototype) {
		auto args = prototype.flatArgs;
		auto functionType = getFunctionType(args.length);
		currentFunction = LLVMAddFunction(moduleRef, toStringz(prototype.name), functionType);
		LLVMSetLinkage(currentFunction, LLVMExternalLinkage);
		
/*		currentFunctionParams.length = flatArgs.length;
		foreach(idx, arg; prototype.flatArgs) {
			currentFunctionParams[arg.name] = LLVMGetParam(currentFunction, idx);
		}*/
	}
	
	void visit(PrototypeArg prototypeArg) {
	}
	
	void visit(Extern externNode) {
	}
	
	void unvisit(ASTNode node) {
	}
}
