import std.math;
import std.c.stdio;

bool even(uint x) {
	return (x & 1) == 0;
}

bool odd(uint x) {
	return !even(x);
}

uint gcd(uint x, uint y) {
	uint u = x;
	uint v = y;
	uint k = 0;
	
	while(u > 0 && v > 0 && u != v) {
//		printf("(u, v) = (%d, %d)\n", u, v);
		if(even(u) && even(v)) {
			u /= 2;
			v /= 2;
			k += 1;
		} else if(even(u) && odd(v)) {
			u /= 2;
		} else if(odd(u) && even(v)) {
			v /= 2;
		} else if(odd(u) && odd(v) && u >= v) {
			u = (u - v) / 2;
		} else {
			uint oldu = u;
			u = (v - u) / 2;
			v = oldu;
		}
	}
	
	if(u == 0) {
		return v;
	} else if(v == 0) {
		return u;
	} else {
		return cast(uint) ldexp(v, k);
	}
}

uint modexpt(ulong b, uint e, ulong m) {
	ulong result = 1;
	
	while(e > 0) {
//		printf("b: %d, e: %d, m: %d, r: %d\n", b, e, m, result);
		
		if(odd(e)) {
			result = (result * b) % m;
		}
		
		b = (b * b) % m;
		e /= 2;
	}
//	printf("b: %d, e: %d, m: %d, r: %d\n", b * b, e, m, result);
	
	return cast(uint) result;
}

bool naiveprime(uint n) {
	uint max = cast(uint) sqrt(cast(float) n);
	for(uint i = 2; i < max; i++) {
		if(gcd(n, i) != 1) {
//			printf("%d can't be prime because it's divisible by %d\n", n, i);
			return false;
		}
	}
	
	return true;
}

void decomposesd(uint n, out uint s, out uint d) {
	s = 0;
	d = n;
	while(even(d)) {
		s += 1;
		d /= 2;
	}
}

bool mr(uint n, uint s, uint d, uint a) {
//	printf("mr(%d, %d, %d, %d)\n", n, s, d, a);
//	printf("a = %d\n", a);

	uint x = modexpt(a, d, n);
//	printf("x = %d\n", x);
	if(x == 1 || x == (n - 1)) {
		return true;
	}
	
	for(uint r = 1; r < s; r++) {
		x = modexpt(x, 2, n);
//		printf("x = %d\n", x);
		if(x == 1) {
			return false;
		}
		if(x == (n - 1)) {
			return true;
		}
	}
	
	return false;
}

bool prime(uint n) {
	if(n == 1) {
		return false;
	} else if(n == 2) {
		return true;
	} else if(n == 3) {
		return true;
	} else if(even(n)) {
		return false;
	} else {
		uint s;
		uint d;
		decomposesd(n - 1, s, d);
//		printf("s, d: %d %d\n", s, d);
		if(n < 1373653) {
			return mr(n, s, d, 2) && mr(n, s, d, 3);
		} else if(n < 9080191) {
			return mr(n, s, d, 31) && mr(n, s, d, 73);
		} else {
			return mr(n, s, d, 2) && mr(n, s, d, 7) && mr(n, s, d, 61);
		}
	}
}

void main() {
//	printf("%d\n", 65539 * 65539);
//	printf("%d\n", modexpt(2, 32769, 65539));
//  printf("%d\n", prime(994507));

	int numRuns;
	scanf("%d", &numRuns);
	for(int i = 0; i < numRuns; i++) {
		int min;
		int max;
		scanf("%d %d", &min, &max);
		for(int n = min; n <= max; n++) {
//			printf("%d: %d\n", n, prime(n));
			if(prime(n)) {
				printf("%d\n", n);
			}
		}
		printf("\n");
  }
//  printf("%d\n", prime(72001));
}
