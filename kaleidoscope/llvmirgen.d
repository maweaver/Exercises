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

int LLVMRealOLT = 4;
int LLVMRealOEQ = 1;
int LLVMRealOGT = 2;

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
	LLVMValueRef LLVMBuildFCmp(LLVMBuilderRef, int, LLVMValueRef, LLVMValueRef, char *);
	LLVMValueRef LLVMBuildCondBr(LLVMBuilderRef, LLVMValueRef, LLVMBasicBlockRef, LLVMBasicBlockRef);
	LLVMValueRef LLVMBuildBr(LLVMBuilderRef, LLVMBasicBlockRef);
	LLVMValueRef LLVMBuildPhi(LLVMBuilderRef, LLVMTypeRef, char *);
	LLVMValueRef LLVMBuildAlloca(LLVMBuilderRef, LLVMTypeRef, char *);
	
	LLVMValueRef LLVMAddGlobal(LLVMModuleRef, LLVMTypeRef, char *);
	void LLVMAddIncoming(LLVMValueRef, LLVMValueRef *, LLVMBasicBlockRef *, uint);
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

struct IfThenElseContext {
	LLVMBasicBlockRef thenBlock;
	LLVMValueRef thenValue;
	LLVMBasicBlockRef elseBlock;
	LLVMValueRef elseValue;
	LLVMBasicBlockRef mergeBlock;
}

class LlvmIrGen: ASTNodeVisitor {
	
	private:
	
	LLVMModuleRef moduleRef;
	LLVMBuilderRef builderRef;
	
	LLVMValueRef printf;
	LLVMValueRef printFormat;
	LLVMValueRef scanf;
	LLVMValueRef scanFormat;

	FunctionContext fnContext;
	IfThenElseContext ifThenElseContext;
	Stack!(LLVMValueRef) expressions;
	
	LLVMTypeRef doubleType;
	LLVMTypeRef intType;
	LLVMTypeRef charType;
	LLVMTypeRef charPtrType;
	LLVMTypeRef charPtrPtrType;
	
	void initLlvm(string name) {
		moduleRef = LLVMModuleCreateWithName(toStringz(name));
		builderRef = LLVMCreateBuilder();
		doubleType = LLVMDoubleType();
		intType = LLVMInt32Type();
		charType = LLVMInt8Type();
		charPtrType = LLVMPointerType(charType, 0);
		charPtrPtrType = LLVMPointerType(charPtrType, 0);
	}
	
	void declarePrintf() {
		LLVMTypeRef[1] printfArgs;
		printfArgs[0] = charPtrType;
		auto printfType = LLVMFunctionType(intType, &printfArgs[0], 1, 1);
		printf = LLVMAddFunction(moduleRef, toStringz("printf"), printfType);
		LLVMSetLinkage(printf, LLVMExternalLinkage);
	}
	
	void declareScanf() {
		LLVMTypeRef[1] scanfArgs;
		scanfArgs[0] = charPtrType;
		auto scanfType = LLVMFunctionType(intType, &scanfArgs[0], 1, 1);
		scanf = LLVMAddFunction(moduleRef, toStringz("scanf"), scanfType);
		LLVMSetLinkage(scanf, LLVMExternalLinkage);
	}

	void declarePrintFormat() {
		LLVMValueRef[5] formatChars;
		formatChars[0] = LLVMConstInt(charType, '%', 0);
		formatChars[1] = LLVMConstInt(charType, 'l', 0);
		formatChars[2] = LLVMConstInt(charType, 'f', 0);
		formatChars[3] = LLVMConstInt(charType, '\n', 0);
		formatChars[4] = LLVMConstInt(charType, '\0', 0);
		auto formatVal = LLVMConstArray(charType, &formatChars[0], 5);
		printFormat = LLVMAddGlobal(moduleRef, LLVMArrayType(charType, 5), toStringz("printformat"));
		LLVMSetInitializer(printFormat, formatVal);
		LLVMSetLinkage(printFormat, LLVMInternalLinkage);
		LLVMSetGlobalConstant(printFormat, 1);
	}
	
	void declareScanFormat() {
		LLVMValueRef[4] formatChars;
		formatChars[0] = LLVMConstInt(charType, '%', 0);
		formatChars[1] = LLVMConstInt(charType, 'l', 0);
		formatChars[2] = LLVMConstInt(charType, 'f', 0);
		formatChars[3] = LLVMConstInt(charType, '\0', 0);
		auto formatVal = LLVMConstArray(charType, &formatChars[0], 4);
		scanFormat = LLVMAddGlobal(moduleRef, LLVMArrayType(charType, 4), toStringz("scanformat"));
		LLVMSetInitializer(scanFormat, formatVal);
		LLVMSetLinkage(scanFormat, LLVMInternalLinkage);
		LLVMSetGlobalConstant(scanFormat, 1);
	}

	void beginOutput() {
		LLVMTypeRef[2] mainArgTypes;
		mainArgTypes[0] = intType;
		mainArgTypes[1] = charPtrPtrType;
		auto mainType = LLVMFunctionType(intType, &mainArgTypes[0], 2, false);
		fnContext.fn = LLVMAddFunction(moduleRef, toStringz("main"), mainType);
		LLVMSetLinkage(fnContext.fn, LLVMExternalLinkage);
		fnContext.block = LLVMAppendBasicBlock(fnContext.fn, "entry");
		LLVMPositionBuilderAtEnd(builderRef, fnContext.block);
	}
	
	void displayOutput(LLVMValueRef value) {
		LLVMValueRef[2] gepOffsets;
		gepOffsets[0] = LLVMConstInt(LLVMInt64Type(), 0, 0);
		gepOffsets[1] = LLVMConstInt(LLVMInt64Type(), 0, 0);
		LLVMValueRef formatArg = LLVMBuildGEP(builderRef, printFormat, &gepOffsets[0], 2, toStringz("gep"));
		LLVMValueRef[2] args;
		args[0] = formatArg;
		args[1] = value;
		LLVMBuildCall(builderRef, printf, &args[0], 2, toStringz("printoutput"));
		LLVMBuildRet(builderRef, LLVMConstInt(intType, 1, 0));
	}
	
	LLVMValueRef retrieveInput() {
		LLVMValueRef[2] gepOffsets;
		gepOffsets[0] = LLVMConstInt(LLVMInt64Type(), 0, 0);
		gepOffsets[1] = LLVMConstInt(LLVMInt64Type(), 0, 0);
		LLVMValueRef formatArg = LLVMBuildGEP(builderRef, scanFormat, &gepOffsets[0], 2, toStringz("gep"));
		
		auto tmp = LLVMBuildAlloca(builderRef, doubleType, toStringz("inputtedDouble"));
		// auto tmpArg = LLVMBuildGEP(builderRef, tmp, &gepOffsets[0], 1, toStringz("tmpGep"));
		
		LLVMValueRef[2] args;
		args[0] = formatArg;
		args[1] = tmp;
		LLVMBuildCall(builderRef, scanf, &args[0], 2, toStringz("scaninput"));
		
		return LLVMBuildLoad(builderRef, tmp, toStringz("loadInputResult"));
	}
		
	
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
		expressions = new Stack!(LLVMValueRef)();
		initLlvm(name);
		declarePrintf();
		declarePrintFormat();
		declareScanf();
		declareScanFormat();

		root.accept(this);
		
		LLVMWriteBitcodeToFile(moduleRef, toStringz(filename));
	}
	
	void postvisit(BinaryExpression binaryExpression) {
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
	
	void postvisit(BooleanExpression booleanExpression) {
		LLVMValueRef rhs = expressions.pop();
		LLVMValueRef lhs = expressions.pop();
		
		LLVMValueRef cmpExpression = null;
		switch(booleanExpression.operation) {
			case '<': cmpExpression = LLVMBuildFCmp(builderRef, LLVMRealOLT, lhs, rhs, toStringz("lttmp")); break;
			case '=': cmpExpression = LLVMBuildFCmp(builderRef, LLVMRealOEQ, lhs, rhs, toStringz("eqtmp")); break;
			case '>': cmpExpression = LLVMBuildFCmp(builderRef, LLVMRealOGT, lhs, rhs, toStringz("gttmp")); break;
		}
		
		if(cmpExpression) {
			expressions.push(cmpExpression);
		}
	}
	
	void postvisit(Call callNode) {
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
	
	void previsit(Extern externNode) {
		resetFunctionContext(FunctionType.external);
	}
	
	void previsit(Function functionNode) {
		resetFunctionContext(FunctionType.defined);
	}
	
	void postvisit(Function functionNode) {
		LLVMBuildRet(builderRef, expressions.pop());
	}
	
	void previsit(If ifNode) {
		ifThenElseContext.mergeBlock = LLVMAppendBasicBlock(fnContext.fn, toStringz("merge"));
	}
	
	void visit(If ifNode) {
		ifThenElseContext.thenBlock = LLVMAppendBasicBlock(fnContext.fn, toStringz("then"));
		ifThenElseContext.elseBlock = LLVMAppendBasicBlock(fnContext.fn, toStringz("else"));
		
		LLVMBuildCondBr(builderRef, expressions.pop(), ifThenElseContext.thenBlock, ifThenElseContext.elseBlock);
	}
	
	void postvisit(If ifNode) {
		fnContext.block = ifThenElseContext.mergeBlock;
		auto phi = LLVMBuildPhi(builderRef, doubleType, toStringz("phi"));
		LLVMAddIncoming(phi, &ifThenElseContext.thenValue, &ifThenElseContext.thenBlock, 1);
		LLVMAddIncoming(phi, &ifThenElseContext.elseValue, &ifThenElseContext.elseBlock, 1);
		expressions.push(phi);
	}
	
	void visit(Input inputNode) {
		expressions.push(retrieveInput());
	}
	
	void previsit(Number number) {
		expressions.push(LLVMConstReal(doubleType, number.val));
	}
	
	void previsit(Output outputNode) {
		resetFunctionContext(FunctionType.defined);
		beginOutput();
	}
	
	void postvisit(Output outputNode) {
		displayOutput(expressions.pop());
	}

	void previsit(Prototype prototype) {
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

	void previsit(ThenElse thenElseNode) {
		LLVMPositionBuilderAtEnd(builderRef, ifThenElseContext.thenBlock);
	}
	
	void visit(ThenElse thenElseNode) {
		LLVMBuildBr(builderRef, ifThenElseContext.mergeBlock);
		LLVMPositionBuilderAtEnd(builderRef, ifThenElseContext.elseBlock);
	}
	
	void postvisit(ThenElse thenElseNode) {
		ifThenElseContext.elseValue = expressions.pop();
		ifThenElseContext.thenValue = expressions.pop();
		LLVMBuildBr(builderRef, ifThenElseContext.mergeBlock);
		LLVMPositionBuilderAtEnd(builderRef, ifThenElseContext.mergeBlock);
	}
	
	void previsit(Variable variable) {
		expressions.push(fnContext.params[variable.name]);
	}
}
