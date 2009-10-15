import std.boxer;
import std.random;
import std.stdio;
import std.string;

class WordPair
{
	public:
	
	string word1;
	string word2;
	
	this(string word1, string word2)
	{
		this.word1 = word1;
		this.word2 = word2;
	}
	
	hash_t toHash() 
	{
		return box(word1).toHash + box(word2).toHash;
	}
	
	bool opEquals(Object o)
	{
		WordPair w = cast(WordPair) o;
		return w && w.word1 == word1 && w.word2 == word2;
	}
	
	int opCmp(Object o)
	{
		WordPair w = cast(WordPair) o;
		if(w) {
			if(w.word1 == word1) {
				return cast(int) box(word2).opCmp(box(w.word2));
			} else {
				return cast(int) box(word1).opCmp(box(w.word1));
			}
		} else {
			return -1;
		}
	}
	
	unittest {
		WordPair w1 = new WordPair("Hello", "World");
		WordPair w2 = new WordPair("Hello", "Moon");
		WordPair w3 = new WordPair("Hello", "World");
		WordPair w4 = new WordPair("Hi", "Sun");
		
		assert(w2 != w1);
		assert(w2 < w1);
		assert(w3 == w1);
		assert(w4 > w1);
	}
}

WordPair[][WordPair] chain;

void followChain(WordPair start, int len)
{
	if(len > 0) {
		writef("%s", start.word1);
		if(len == 1) {
			if(start.word1[$ - 1] != '.') {
				writefln(".");
			} else {
				writefln("");
			}
		} else if(start.word1[$ - 1] == '.' && start.word1 != "Mr." && start.word1 != "Mrs." && start.word2[0] >= 'A' && start.word2[0] <= 'Z' && uniform(0, 100) > 80) {
			writefln("\n");
		} else {
			writef(" ");
		}
		auto choices = chain[start];
		followChain(choices[uniform(0, choices.length)], len - 1);
	}
}

int main()
{
	string word1;
	string word2;
	string word3;

	auto f = File("markov.txt", "r");
	string line;
	while(!((line = f.readln()) is null)) {
		string[] words = split!(string)(line);
		foreach(word; words) {
			word1 = word2;
			word2 = word3;
			word3 = word;
			
			if(word1 && word2 && word3) {
				WordPair pair1 = new WordPair(word1, word2);
				WordPair pair2 = new WordPair(word2, word3);
				
				chain[pair1] ~= pair2;
			}
		}
	}
	int randIdx = uniform(0, chain.length);
	int curIdx = 0;
	foreach(wp, next; chain) {
		if(curIdx >= randIdx && wp.word1[0] >= 'A' && wp.word1[0] <= 'Z') {
			followChain(wp, 500);
			break;
		}
		curIdx++;
	}
	
	
	return 0;
}
