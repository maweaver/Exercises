import std.random;
import std.stdio;
import std.c.stdio;

import util.elliptic;
import util.wrappedint;

int binaryGcd(int u, int v) {
	int shift;
 
  /* GCD(0,x) := x */
  if(u == 0 || v == 0)
    return u | v;
 
	/* Let shift := lg K, where K is the greatest power of 2
	  dividing both u and v. */
	for(shift = 0; ((u | v) & 1) == 0; ++shift) {
		u >>= 1;
		v >>= 1;
	}
 
	while ((u & 1) == 0)
		u >>= 1;
 
	/* From here on, u is always odd. */
	do {
		while ((v & 1) == 0)  /* Loop X */
			v >>= 1;
 
		/* Now u and v are both odd, so diff(u, v) is even.
		Let u = min(u, v), v = diff(u, v)/2. */
		if (u < v) {
			v -= u;
		} else {
			int diff = u - v;
			u = v;
			v = diff;
		}
		v >>= 1;
	} while (v != 0);
 
	return u << shift;
}

void main() {
	int num;
	writef("Number to factor: ");
	scanf("%d", &num);

	// Create a curve that wraps around the number, with a = 4, b = -a, and
	// k = num
	auto a = uniform(0, num);
	auto b = -a;
	auto curve = new IntEllipticCurve(a, b, num);
	
	// (1, 1) is guaranteed to be a point on such a curve (since 1 ^ 3 = 1 ^ 2 + 
	// a * 1 - a)
	auto p = new IntEllipticCurvePoint(new WrappedInt(1, num), new WrappedInt(1, num), curve);
	auto curP = p;
	for(int i = 0; i < num; i++) {
		try {
			curP = curP + p;
		} catch(Exception e) {
			auto gcd = binaryGcd(curP.x.val - 1, num);
			writefln("%d x %d = %d", gcd, num / gcd, num);
			return;
		}
	}
	
	writefln("No errors found (prime?)");
}
