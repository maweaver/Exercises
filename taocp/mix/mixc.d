import mixal;
import std.getopt;
import std.stdio;

extern(C) {
	void yysetdebug(int);
	int yylex();
	int yyparse();
	void yyrestart(FILE *);
}

void main(string[] args) {
	string inFilename;
	bool debugLexer = false;
	bool debugParser = false;
	bool verbose = false;
	bool help = false;
	
	getopt(args,
		"input|i", &inFilename,
		"verbose|v", &verbose,
		"debug-lexer|dl", &debugLexer,
		"debug-parser|dp", &debugParser,
		"help|h", &help
	);
	
	if(help || inFilename is null) {
		showHelp();
		return;
	}
	
	if(verbose) {
		writefln("Compiling file %s:", inFilename);
		writeln();
	}
	
	auto inFile = new File(inFilename, "r");
	yyrestart(inFile.getFP());
	
	if(debugLexer) {
		yysetdebug(1);
		while(yylex() != 0) { }
		return;
	}
	
	if(debugParser) {
		mixal.debugParser = true;
		try {
			yyparse();
		} catch(Exception e) {
			writefln("Compilation error: %s", e.msg);
		}
	}
}

void showHelp() {
	writeln("MIX compiler");
	writeln("Usage: mixc [options]");
	writeln();
	writeln("  --input");
	writeln("  --i             Input filename");
	writeln();
	writeln("  --verbose");
	writeln("  --v             Verbose output");
	writeln();
	writeln("  --debug-lexer");
	writeln("  --dl            Shows output from lexer and stops");
	writeln();
	writeln("  --debug-parser");
	writeln("  --dp            Shows output from parser and stops");
	writeln();
	writeln("  --help");
	writeln("  --h             Show this help");
}
