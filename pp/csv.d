import std.file;
import std.stdio;

void parseCsvString(string str, void delegate(string, int, int) fn, char sep = ',')
{
	int row = 0, col = 0;
	string curRecord = "";
	
	int pos = 0;
	
	void delegate() readFieldFp;
	void delegate() readQuotedFieldFp;
	void delegate() readNewlineFp;
	
	void readField() {
		if(pos >= str.length) {
			return;
		}
		
		if(str[pos] == sep) {
			pos++;
		}
		
		curRecord = "";
		if(str[pos] == '"') {
			pos++;
			readQuotedFieldFp();
		} else {
			while(pos < str.length && str[pos] != sep && str[pos] != '\r' && str[pos] != '\n') {
				curRecord ~= str[pos];
				pos++;
			}
			fn(curRecord, row, col);
			col++;
			readNewlineFp();
		}
	}
	
	void readQuotedField() {
		if(pos >= str.length) {
			return;
		}

		while(pos < str.length && str[pos] != '"' || 
			(pos < str.length - 1 && str[pos] == '"' && str[pos + 1] == '"')) {
		
			curRecord ~= str[pos++];
			if(str[pos - 1] == '"') {
				pos++;
			}
		}
		pos++;
		fn(curRecord, row, col);
		col++;
		readNewlineFp();
	}
	
	void readNewline() {
		if(pos >= str.length) {
			return;
		}

		if(pos < str.length && (str[pos] == '\r' || str[pos] == '\n')) {
			row++;
			col = 0;
		}
		while(pos < str.length && (str[pos] == '\r' || str[pos] == '\n')) {
			pos++;
		}
		readFieldFp();
	}
	
	readFieldFp = &readField;
	readQuotedFieldFp = &readQuotedField;
	readNewlineFp = &readNewline;

	readField();	
}

void main(string[] args) {
	auto filename = args[1];
	auto contents = cast(string)(read(filename));
	
	void debugCsvDelegate(string record, int row, int col) {
		if(col == 0 && row != 0) {
			writefln("");
		}
		writef("%s|", record);
	}

	parseCsvString(contents, &debugCsvDelegate, '|');
}
