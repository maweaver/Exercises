module util.test;

import std.stdio;

import util.qsort;

void main() {
	bool increasing(int a, int b) {
		return a > b;
	}

	int[] test = [ 5, 1, 9, 2, 3, 7, 4, 8, 6 ];
	qsort!(int)(test, &increasing);

	writef("[");
	foreach(t; test) {
		writef(" %d ", t);
	}
	writefln("]");
}