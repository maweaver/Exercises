import std.conv;
import std.stdio;
import std.string;
import util.stack;

void main() {
	auto s = new Stack!(real)();
		
	string[] words = split(readln());
	foreach(word; words) {
		real res;
		
		if(word == "+") {
			res = s.pop() + s.pop();
		} else if(word == "-") {
			res = -s.pop() + s.pop();
		} else if(word == "*") {
			res = s.pop() * s.pop();
		} else if(word == "/") {
			res = 1.0 / s.pop() * s.pop();
		} else if(isNumeric(word)) {
			res = to!(real)(word);
		} else {
			writefln("Unexpected word %s", word);
			return;
		}
		
		s.push(res);
	}
	
	writefln("%f", s.pop());
}
