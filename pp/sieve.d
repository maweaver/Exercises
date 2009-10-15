import std.math;
import std.stdio;

int[] sieve(int max) {
	bool[] sieved = new bool[max];
	
	foreach(ref s; sieved) {
		s = true;
	}
	sieved[0] = false;
	
	int maxs = cast(int) sqrt(cast(real) max);
	int curs = 2;
	while(curs < maxs) {
		for(int i = curs + curs; i < max; i += curs) {
			sieved[i] = false;
		}
		
		for(int i = curs + 1; i <= maxs; i++) {
			curs = i;
			if(i < maxs && sieved[i]) {
				break;
			}
		}
	}
	
	int[] res;
	foreach(idx, s; sieved) {
		if(s) {
			res ~= idx;
		}
	}
	return res;
}

void main() {
	writefln("%d", sieve(15485863).length);
}
