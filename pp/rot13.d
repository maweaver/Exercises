import std.stdio;

char[] rot13(string s) {
	char[] ret;
	
	char rotChar(char c, char base) {
		return cast(char)(((c - base) + 13) % 26 + base);
	}
	
	foreach(c; s) {
		if(c >= 'a' && c <= 'z') {
			ret ~= rotChar(c, 'a');
		} else if(c >= 'A' && c <= 'Z') {
			ret ~= rotChar(c, 'A');
		} else {
			ret ~= c;
		}			
	}
	
	return ret;
}

void main() {
	writefln("%s", rot13("Cebtenzzvat Cenkvf vf sha!"));
}
