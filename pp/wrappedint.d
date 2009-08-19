import std.math;
import std.stdio;
import std.string;

/++
 + An integer with value 'val' in a finite set with order k consisting of all 
 + the integers from 0 to k - 1.
 +
 + Addition, subtraction, and multiplication are all performed modulo k so, that
 + the set acts as a ring.
 +
 + Division is only well-defined if there is an inverse of the value, that is a 
 + number q such that val * q - 1 % k = 0.  It can be shown that this is only 
 + true when gcd(q, k) = 1, so division is well-defined over the entire ring 
 + only in the case where k is prime.  In this case, it becomes an integer field
 + rather than just a ring.
 +/
class WrappedInt {
	
	int _val;
	int _k;
	
	/++
	 + Calculates the floor (round towards negative infinity) of D/d, without
	 + bothering to find the value of the decimal D/d.  For D>0, d>0 or D<0, d<0
	 + this is just the truncated D/d.  In other cases, it's D/d - 1.
	 +/
	int rationalFloor(int D, int d) {
		if((D < 0 && d < 0) || (D > 0 && d > 0)) {
			return D / d;
		} else {
			return D / d - 1;
		}
	}
	
	/++
	 + Calculates p % k.  Ensures correct behavior over negative integers.
	 +/
	int mod(int p, int k) {
		if(p >= 0 && p < k) {
			return p;
		} else {
			return p - k * rationalFloor(p, k);
		}
	}
	
	/++
	 + Calculates the inverse of p, that is q such that q * p = 1 (mod k)
	 +/
	int inverse(int p, int k) {
		if(p == 0) {
			// 0 * 0 = 0
			return 0;
		} else if(p == 1) {
			// 1 * 1 = 1 (assumes k > 1)
			return 1;
		}
		
		auto x = k;
		auto y = p;
		int[2] ps; ps[0] = 0; ps[1] = 1;
		int[2] qs;
		auto i = 0;
		int r;
		bool rWasOne = false;
		
		do {
			auto q = x / y;	
			r = mod(x, y);
			
			if(i > 1) {
				auto p2 = mod(ps[0] - qs[0] * ps[1], k);
				ps[0] = ps[1];
				ps[1] = p2;
			}
			qs[0] = qs[1];
			qs[1] = q;
			
			x = y;
			y = r;
			
			if(r == 1) {
				rWasOne = true;
			}
			
			i++;
		} while(r > 0)
		
		if(!rWasOne) {
			throw new Exception("No inverse for " ~ std.string.toString(p) ~ " (mod " ~ std.string.toString(k) ~ ")");
		}
		
		return mod(ps[0] - qs[0] * ps[1], k);
	}

	public:
	
	/++
	 + Constructor.
	 +/
	this(int val, int k) {
		_k = k;
		_val = mod(val, k);
	}
	
	/++
	 + The integer value
	 +/
	int val() {
		return _val;
	}
	
	/++
	 + The point at which wrapping occurs
	 +/
	int k() {
		return _k;
	}
	
	/++
	 + Allows this value to be used as an integer
	 +/
	int opCast() {
		return val;
	}
	
	/++
	 + Add an integer to a wrapped integer, or vice versa
	 +/
	WrappedInt opAdd(int o) {
		return new WrappedInt(mod(o, k) + val, k);
	}
	
	/++
	 + Add two wrapped integers.  They must have the same order.
	 +/
	WrappedInt opAdd(WrappedInt o) {
		if(k != o.k) {
			throw new Exception("Range " ~ std.string.toString(o.k) ~ " does not match expected range " ~ std.string.toString(k));
		}

		return new WrappedInt(o.val + val, k);
	}
	
	/++
	 + Subtract an integer from a wrapped integer
	 +/
	WrappedInt opSub(int o) {
		return new WrappedInt(val - mod(o, k), k);
	}
	
	/++
	 + Subtracts two wrapped integers.  They must have the same order.
	 +/
	WrappedInt opSub(WrappedInt o) {
		if(k != o.k) {
			throw new Exception("Range " ~ std.string.toString(o.k) ~ " does not match expected range " ~ std.string.toString(k));
		}

		return new WrappedInt(val - o.val, k);
	}
	
	/++
	 + Subtract a wrapped integer from an integer
	 +/
	WrappedInt opSub_r(int o) {
		return new WrappedInt(mod(o, k) - val, k);
	}
	
	/++
	 + Multiply a wrapped integer by an integer, or vice versa
	 +/
	WrappedInt opMul(int o) {
		return new WrappedInt(mod(o, k) * val, k);
	}
	
	/++
	 + Multiply two wrapped integers together.  They must have the same order.
	 +/
	WrappedInt opMul(WrappedInt o) {
		if(k != o.k) {
			throw new Exception("Range " ~ std.string.toString(o.k) ~ " does not match expected range " ~ std.string.toString(k));
		}

		return new WrappedInt(o.val * val, k);
	}
	
	/++
	 + Divide a wrapped integer by an integer.
	 +/
	WrappedInt opDiv(int o) {
		return this * inverse(o, k);
	}
	
	/++
	 + Divides two wrapped integers.  They must have the same order.
	 +/
	WrappedInt opDiv(WrappedInt o) {
		if(k != o.k) {
			throw new Exception("Range " ~ std.string.toString(o.k) ~ " does not match expected range " ~ std.string.toString(k));
		}

		return new WrappedInt(val * inverse(o.val, k), k);
	}
	
	/++
	 + Divide an integer by a wrapped integer.
	 +/
	WrappedInt opDiv_r(int o) {
		return new WrappedInt(o * inverse(val, k), k);
	}
	
	/++
	 + Returns the negative of this (which will be a positive number between 0 and
	 + k.
	 +/
	WrappedInt opNeg() {
		return new WrappedInt(-val, k);
	}

	/++
	 + Calculates (val ^ e) % k, using left-to-right binary modular exponentiation
	 + (meaning val ^ e is never calculated directly)
	 +/
	WrappedInt pow(int e) {
		long result = 1;
		auto b = val;
		
		while(e > 0) {
			if(e & 1 != 0) {
				result = (result * b) % k;
			}
		
			b = (b * b) % k;
			e /= 2;
		}

		return new WrappedInt(cast(int) result, k);
	}
	
	/++
	 + Return val ^ 2
	 +/
	WrappedInt square() {
		return this * this;
	}
	
	/++
	 + Calculates the square root using a naive method--loop through all x,
	 + 0 <= x < k, and check if x * x == val.
	 +
	 + The square root is only defined if there are two roots, in which case they
	 + are always the negative of each other.  If there are no roots, or if there 
	 + are more than two roots, an exception is thrown.
	 +/
	WrappedInt[] sqrt() {
		WrappedInt[] res = new WrappedInt[2];
		int numRoots = 0;
		
		for(int x = 0; x < k; x++) {
			auto squared = mod(x * x, k);
			if(squared == val) {
				if(numRoots < 2) {
					res[numRoots] = new WrappedInt(x, k);
				}
				numRoots++;
			}
		}
		
		if(numRoots == 0) {
			throw new Exception("No square root exists for " ~ std.string.toString(val) ~ " (mod " ~ std.string.toString(k) ~ ")");
		} else if(numRoots == 1) {
			throw new Exception("Expected two roots for " ~ std.string.toString(val) ~ ", but only one was found (" ~ std.string.toString(res[0].val) ~ ")");
		} else if (numRoots > 2) {
			throw new Exception("Expected two roots for " ~ std.string.toString(val) ~ ", but found " ~ std.string.toString(numRoots));
		} else {
			return res;
		}
	}
	
	/++
	 + Returns 1/val
	 +/
	WrappedInt invert() {
		return new WrappedInt(inverse(val, k), k);
	}
	
	/++
	 + Compares two wrapped integers for equality.  True if the order of both is
	 + the same, and the value is the same.
	 +/
	int opEquals(Object o) {
		auto owi = cast(WrappedInt) o;
		if(owi) {
			return owi.k == k && owi.val == val;
		} else {
			return 0;
		}
	}
	
	/++
	 + Ordered comparison.  Be careful with this, results may be unintuitive;
	 + e.g. WrappedInt(k - 1, k) > WrappedInt(k, k)
	 +/
	int opCmp(Object o) {
		auto owi = cast(WrappedInt) o;
		if(owi) {
			if(owi.k == k) {
				return val - owi.val;
			} else {
				throw new Exception("Can't compare WrappedInt with order " ~ std.string.toString(k) ~ " to one with order " ~ std.string.toString(owi.k));
			}
		} else {
			throw new Exception("Attempted to compare WrappedInt with incomparable type");
		}
	}
	
	unittest {
		// Variables
		auto negFive = new WrappedInt(-5, 12);
		auto three = new WrappedInt(3, 12);
		auto four = new WrappedInt(4, 12);
		auto seven = new WrappedInt(7, 12);
		auto eight = new WrappedInt(8, 12);
		auto nine = new WrappedInt(9, 12);
		
		// Mod
		writefln("-5 mod 12 = 7 [%d]", negFive.val);
		assert(negFive.val == 7);
		
		// Negate
		writefln("-(-5) mod 12 = 5 [%d]", (-negFive).val);
		assert((-negFive).val == 5);
		
		// Comparison
		writefln("3 < -5 (mod 12) [%d]", three < negFive);
		assert(three < negFive);
		
		// Equality
		writefln("5 == 17 (mod 12) [%d]", new WrappedInt(5, 12) == new WrappedInt(17, 12));
		assert(new WrappedInt(5, 12) == new WrappedInt(17, 12));
		
		// Addition
		writefln("9 + 8 = 5 (mod 12) [%d]", cast(int) (nine + eight));
		assert((9 + eight).val == 5);
		assert((nine + 8).val == 5);
		assert((nine + eight).val == 5);
		
		// Subtraction
		writefln("4 - 9 = 7 (mod 12) [%d]", (four - nine).val);
		assert((4 - nine).val == 7);
		assert((four - 9).val == 7);
		assert((four - nine).val == 7);
		
		// Multiplication
		writefln("3 * 7 = 9 (mod 12) [%d]", (three * seven).val);
		assert((3 * seven).val == 9);
		assert((three * 7).val == 9);
		assert((three * seven).val == 9);
		
		// Division
		writefln("9 / 7 = 3 (mod 12) [%d]", (nine / 7).val);
		assert((nine / 7).val == 3);
		assert((9 / seven).val == 3);
		assert((nine / seven).val == 3);
		
		// Exponentiation
		writefln("3 ^ 4 = 9 (mod 12) [%d]", three.pow(4).val);
		assert(three.pow(4).val == 9);
		
		// Square Root
		auto sqrts = (new WrappedInt(9, 13)).sqrt();
		writefln("sqrt(9) = 3, 10 (mod 13) [%d, %d]", sqrts[0].val, sqrts[1].val);
		assert(sqrts[0] == new WrappedInt(3, 13));
		assert(sqrts[1] == new WrappedInt(10, 13));
		assert(sqrts[0] == -sqrts[1]);
		assert(sqrts[1] == -sqrts[0]);
	}
}
