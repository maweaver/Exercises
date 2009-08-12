import std.math;
import std.stdio;
import std.c.stdio;

class Lockers {
	bool[] toggled;
	int n;
	
	this(int n) {
		this.n = n;
		toggled.length = n;
		for(int i = 0; i < n; i++) {
			toggled[i] = false;
		}
	}
	
	int[] jockeyForce() {
		for(int i = 0; i < n; i++) {
			for(int j = 0; j < n; j++) {
				if((j + 1) % (i + 1) == 0) {
					toggled[j] = !toggled[j];
				}
			}
		}
		
		int[] result;
		for(int i = 0; i < n; i++) {
			if(toggled[i]) {
				result.length = result.length + 1;
				result[result.length - 1] = (i + 1);
			}
		}
		
		return result;
	}
	
	int[] nerdForce() {
		int upperLimit = cast(int) sqrt(cast(real) (n + 1));
		int[] result;
		result.length = upperLimit;
		for(int i = 0; i < result.length; i++) {
			result[i] = (i + 1) * (i + 1);
		}
		return result;
	}
}

void printArray(string prefix, int[] array) {
	writef("%s: { ", prefix);
	foreach(r; array) {
		writef("%d ", r);
	}
	writefln("}");
}

void main() {
	int n;
	writef("Num Lockers: ");
	scanf("%d", &n);
	
	auto lockers = new Lockers(n);
	printArray("Jockeys ", lockers.jockeyForce());
	printArray("Nerds   ", lockers.nerdForce());
}
