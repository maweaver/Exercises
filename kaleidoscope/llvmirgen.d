import ast;
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
	
	LLVMValueRef LLVMConstReal(LLVMTypeRef t, double n);
	LLVMValueRef LLVMAddFunction(LLVMModuleRef m, char *name, LLVMTypeRef fType);
	void LLVMSetLinkage(LLVMValueRef Global, int Linkage);
	
	LLVMDisposeMessage(char *message);
}

class LlvmIrGen: ASTNodeVisitor {
	
	private:
	
	LLVMModuleRef moduleRef;
	LLVMBuilderRef builderRef;
	
	LLVMTypeRef doubleType;
	LLVMValueRef[] parentValues;
	
	LLVMValueRef currentFunction;
	LLVMValueRef[string] curentFunctionParams;
	LLVMValueRef[] expressions;
	
	LLVMTypeRef getFunctionType(int numParams) {
		LLVMTypeRef[] params;
		params.length = numParams;
		for(int i = 0; i < numParams; i++) {
			params[i] = doubleType;
		}
		return LLVMFunctionType(doubleType, cast(LLVMTypeRef*) params, numParams, 0);
	}
	
	public:
	
	LLVMModuleRef generateModule(string name, ASTRootNode root) {
		moduleRef = LLVMModuleCreateWithName(toStringz(name));
		builderRef = LLVMCreateBuilder();
		doubleType = LLVMDoubleType();
		
		root.visit(this);
		
		LLVMDumpModule(moduleRef);
		return moduleRef;
	}
	
	void visit(ASTRootNode rootNode) {
	}
	
	void visit(Number number) {
		expressions.length += 1;
		expressions[expressions.length - 1] = LLVMConstReal(doubleType, number.val);
	}
	
	void visit(Variable variable) {
		expressions.length += 1;
		expressions[expressions.length - 1] = currentFunctionParams[variable.name];
	}
	
	void visit(BinaryExpression binaryExpression) {
		LLVMValueRef lhs = expressions[expressions.length - 3];
		LLVMValueRef rhs = expressions[expressions.length - 2];
		
		LLVMValueRef comboExpression = null;
		switch(binaryExpression.op) {
			case '+': comboExpression = LLVMBuildAdd(builderRef, lhs, rhs, "addtmp"); break;
			case '-': comboExpression = LLVMBuildSub(builderRef, lhs, rhs, "subtmp"); break;
			case '*': comboExpression = LLVMBuildMul(builderRef, lhs, rhs, "multmp"); break;
			case '/': comboExpression = LLVMBuildFDiv(builderRef, lhs, rhs, "divtmp"); break;
			default: LLVMDisposeMessage(toStringz("Unexpected operator '" ~ binaryExpression.op ~ "'")); break;
		}
		
		if(comboExpression) {
			expressions.length -= 1;
			expressions[expressions.length - 1] = comboExpression;
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
		
		currentFunctionParams.length = flatArgs.length;
		for(idx, arg; prototype.flatArgs) {
			currentFunctionParams[arg.name] = LLVMGetParam(currentFunction, idx);
		}
	}
	
	void visit(PrototypeArg prototypeArg) {
	}
	
	void visit(Extern externNode) {
	}
	
	void visit(ASTNode node) {
	}
	
	void unvisit(ASTNode node) {
	}
}
