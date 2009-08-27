import std.stdio;
import std.conv;

int[string] symbolIndexes;
int[] symbolValues;

int currentLoc;

bool debugParser = false;

int internSymbol(string name) {
	auto index = symbolValues.length;
	symbolValues.length = index + 1;
	symbolIndexes[name] = index;
	return index;
}
	
extern(C) {
	
	int mixal_symbol_decl(char *cName) {
		auto name = to!(string)(cName);
		auto index = internSymbol(name);
		
		if(debugParser) {
			writefln("Declaring symbol %s to index %d", name, index);
		}
		
		return index;
	}
	
	int mixal_symbol_ref(char *cName) {
		auto name = to!(string)(cName);
		
		if(name in symbolIndexes) {
			auto index = symbolIndexes[name];
			auto value = symbolValues[index];
			
			if(debugParser) {
				writefln("Symbol %s[%d] replaced with %d", name, index, value);
			}
			
			return value;
		} else {
			throw new Exception("Reference to undefined symbol '" ~ name ~ "'");
		}
	}
	
	int mixal_self() {
		if(debugParser) {
			writefln("Self: %d", currentLoc);
		}
		return currentLoc;
	}
	
	int mixal_eq(int index, int value) {
		if(index < symbolValues.length) {
			if(debugParser) {
				writefln("Setting symbol [%d] to %d", index, value);
			}
			symbolValues[index] = value;
			return currentLoc;
		} else {
			throw new Exception("Internal error: reference to undefined symbol with index " ~ to!(string)(index) ~ " and value " ~ to!(string)(value));
		}
	}
	
	int mixal_orig(int address) {
		if(debugParser) {
			writefln("Setting originating address to %d", address);
		}
		
		currentLoc = address;
		return currentLoc;
	}
	
	int mixal_operator(int op, int a, int i, int f) {
		if(debugParser) {
			writefln("Operator %d, a=%d, i=%d, f=%d", op, a, i, f);
		}
		
		return currentLoc;
	}
}
