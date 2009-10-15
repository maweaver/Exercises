import std.stdio;

int bruteForceSchemey(string pat, string str, int start = 0) {
	int loop(int strOff, int patOff) {
		if(strOff == str.length && patOff != pat.length) {
			return -1;
		} else if(patOff == pat.length) {
			return strOff - patOff;
		} else if(str[strOff] == pat[patOff]) {
			return loop(strOff + 1, patOff + 1);
		} else {
			return loop(strOff - patOff + 1, 0);
		}
	}
	
	return loop(start, 0);
}

int bruteForceImperative(string pat, string str, int start = 0) {
	int strOff = start; 
	int patOff = 0;
	
	while(strOff != str.length) {
		if(patOff == pat.length) {
			break;
		} else if(str[strOff] == pat[patOff]) {
			strOff++;
			patOff++;
		} else {
			strOff = strOff - patOff + 1;
			patOff = 0;
		}
	}
	
	return patOff == pat.length ? strOff - patOff : -1;
}

int bruteForceNestedLoops(string pat, string str, int start = 0) {
	
	foreach(stridx, strch; str[start..$]) {
		
		bool found = true;
		foreach(patidx, patch; pat) {
			if(stridx + patidx >= str.length) {
				found = false;
				break;
			}
			if(patch != str[start + stridx + patidx]) {
				found = false;
				break;
			}
		}
		
		if(found) {
			return stridx + start;
		}
		
	}
	return -1;
}

int kmdPp(string pat, string str, int start = 0) {
	
	int[] buildTable(string pat) {
		auto t = new int[pat.length];
		if(t.length > 0) {
			t[0] = 0;
		}
	
		for(int i = 1; i < t.length; i++) {
			int len = t[i - 1] + 1;
		
			if(pat[len - 1] == pat[i]) {
				t[i] = len;
			} else if(pat[0] == pat[i]) {
				t[i] = 1;
			} else {
				t[i] = 0;
			}
		}
		
		return t;
	}
	
	auto t = buildTable(pat);
	
	int m = start; int i = 0;
	while(true) {
		if(i >= pat.length) {
			return m - i;
		} else if(m >= str.length) {
			return -1;
		} else if(str[m] == pat[i]) {
			m++;
			i++;
		} else if(i > 0) {
			i = t[i - 1];
		} else {
			m++;
		}
	}
	
	return -1;
}

int kmdWp(string pat, string str, int start = 0) {
	
	int[] buildTable(string pat) {
		auto t = new int[pat.length];
		if(t.length > 0) {
			t[0] = -1;
		}
		
		if(t.length > 1) {
			t[1] = 0;
		}
	
		for(int i = 2; i < t.length; i++) {
			int len = t[i - 1] + 1;
		
			if(pat[len - 1] == pat[i - 1]) {
				t[i] = len;
			} else if(pat[0] == pat[i - 1]) {
				t[i] = 1;
			} else {
				t[i] = 0;
			}
		}
		
		return t;
	}
	
	auto t = buildTable(pat);
	
	auto m = start;
	int i = 0;
	while(m + i < str.length) {
		if(pat[i] == str[m + i]) {
			i++;
			if(i == pat.length) {
				return m;
			}
		} else {
			m = m + i - t[i];
			if(i > 0) {
				i = t[i];
			}
		}
	}
	
	return -1;
}

typedef int function(string, string, int) SearchFunction;

void testSearch(string name, SearchFunction fn) {
	writefln("Testing search using %s algorithm", name);
	
	auto pp = "Programming Praxis";
	
	testSearchStr(fn, pp, pp, 0);
	testSearchStr(fn, "Praxis", pp, 12);
	testSearchStr(fn, "Prax", pp, 12);
	testSearchStr(fn, "praxis", pp, -1);
	testSearchStr(fn, "P", pp, 0);
	testSearchStr(fn, "P", pp, 12, 5);
	testSearchStr(fn, "mi", pp, 7);
	testSearchStr(fn, "ABABAC", "ABABABAC", 2);
	testSearchStr(fn, "ABCDABD", "ABC ABCDAB ABCDABCDABDE", 15);
	
	writefln("");
}

void testSearchStr(SearchFunction fn, string pat, string str, int expected, int start = 0) {
	writefln("%s[%s] == %d [%d]", str, pat, expected, fn(pat, str, start));
	assert(fn(pat, str, start) == expected);
}

void main() {
	testSearch("brute force (schemey)", &bruteForceSchemey);
	testSearch("brute force (imperative)", &bruteForceImperative);
	testSearch("brute force (nested loops)", &bruteForceNestedLoops);
	testSearch("kmd (programming praxis)", &kmdPp);
	testSearch("kmd (wikipedia)", &kmdWp);
}
