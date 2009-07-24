import std.stdio;
import std.string;

/++

Many problems have solutions involving linear recurrence equations of the form 
$(EQN f(n) = a * f(n-1) + b * f(n-2) (n >= 2)). Usually the coefficients $(EQN a) and $(EQN b) are between 
$(DDOC_PSYMBOL 0) and $(DDOC_PSYMBOL 10), so it would be useful to have a program which checks if some given values can be 
produced by such a recurrence equation. Since the growth of the values $(EQN f(n)) can be exponential, we 
will consider the values modulo some integer constant $(EQN k).

More specifically you will be given $(EQN f(0)), $(EQN f(1)), $(EQN k) and some value pairs 
$(EQN (i , xi)), where $(EQN xi) is the remainder of the division of $(EQN f(i)) by $(EQN k).

You have to determine coefficients $(EQN a) and $(EQN b) for the recurrence equation $(EQN f) such that 
for each given value pair $(EQN (i, xi)) the equation $(EQN xi = f(i) mod k) holds.

$(DDOC_SECTION_H Hints)

You can write the recurrence equation as follows:
$(EQN_ML
| a b | | f(n - 1) | = | f(n)     |
| 1 0 | | f(n - 2) |   | f(n - 1) |)
Let
$(EQN_ML
A := | a b |
     | 1 0 |)
Then, 
$(EQN_ML
A<sup>n</sup> * | f(1) | = | f(n + 1) |
     | f(0) |   | f(n)     |)
These equations also apply if everything is calculated modulo $(EQN k). To speed up the calculation of 
$(EQN A<sup>n</sup>), the identity 
$(EQN A<sup>n</sup> = (A<sup>n/2</sup>)<sup>2</sup> * A<sup>n mod 2</sup>) may be used. Also, 
$(EQN (a * b) mod c = ((a mod c) * (b mod c)) mod c).

$(DDOC_SECTION_H Input)

The first line of the input contains a number $(EQN T <= 20) which indicates the number of 
test cases to follow.

Each test case consists of 3 lines. The first line of each test case contains the three integers 
$(EQN f(0)), $(EQN f(1)) and $(EQN k), where $(EQN 2 <= k <= 100000) and $(EQN 0 <= f(0)), $(EQN f(1) < k). 
The second line of each test case contains a number $(EQN m <= 10) indicating the number of value pairs in 
the next line. The third line of each test case contains $(EQN m) value pairs $(EQN (i,xi)), where 
$(EQN 2 <= i <= 1000000000) and $(EQN 0 <= xi < k).

$(DDOC_SECTION_H Output)

For each test case print one line containing the values $(EQN a) and $(EQN b) separated by a space character, 
where $(EQN 0 <= a,b <= 10). You may assume that there is always a unique solution.

$(DDOC_SECTION_H Example)

Input:
$(CONSOLE
2
1 1 1000
3
2 2 3 3 16 597
0 1 10000
4
11 1024 3 4 1000000000 4688 5 16)

Output:
$(CONSOLE
1 1
2 0)

Macros:
EQN = $(BLUE <code>$0</code>)
EQN_ML = $(BLUE <pre>$0</pre>)
CONSOLE = $(GREEN <pre>$0</pre>)
+/

void main() {
	/*
	for(int i = 0; i < 10; i++) {
		for(int j = 0; j < 10; j++) {
			auto x = new ModUint(i, 3);
			auto y = new ModUint(j, 3);
	
			writefln("%d [%d]", (x + y).val, ((i + j) % 3));
			writefln("%d [%d]", (x * y).val, ((i * j) % 3));
		}
	}
	*/

	/*
	A a = new A(new ModUint(1, 5), new ModUint(2, 5), new ModUint(3, 5), new ModUint(4, 5));
	writefln("a:\n%s\n", a.toString());
	writefln("a*a:\n%s\n", (a * a).toString());
	writefln("a^2:\n%s\n", (a ^ 2).toString());
	writefln("(a*a)*a:\n%s\n", ((a * a) * a).toString());
	writefln("a*(a*a):\n%s\n", (a * (a * a)).toString());
	writefln("a^3:\n%s\n", (a ^ 3).toString());
	writefln("(a*a)*(a*a):\n%s\n", ((a * a) * (a * a)).toString());
	writefln("a*(a*a*a):\n%s\n", (a * (a * a * a)).toString());
	writefln("a^4:\n%s\n", (a ^ 4).toString());
	writefln("a*a*a*a*a:\n%s\n", (a * a * a * a * a).toString());
	writefln("a^5:\n%s\n", (a ^ 5).toString());
	*/
	int numTestCases;
	scanf("%d\n", &numTestCases);
	for(int n = 0; n < numTestCases; n++) {
		int f0;
		int f1;
		int k;
		int numPairs;
		scanf("%d %d %d\n%d", &f0, &f1, &k, &numPairs);
		int modF0 = f0 % k;
		int modF1 = f1 % k;
		int[int] pairs;
		for(int j = 0; j < numPairs; j++) {
			int i;
			int xi;
			scanf("%d %d", &i, &xi);
			pairs[i] = xi;
		}
		
/*		writefln("f(0) : %d", f0);
		writefln("f(1) : %d", f1);
		writefln("k    : %d", k);
		writefln("np  : %d", numPairs);*/
		bool[121] possibleAbs;
		foreach(ab, poss; possibleAbs) {
			possibleAbs[ab] = true;
		}

		foreach(i, xi; pairs) {
			
/*			writefln("(%d, %d)", i, xi); */

			foreach(ab, pos; possibleAbs) {
				
				if(pos) {
					auto an = new A(ab / 11, ab % 11, k) ^ (i - 1);
					auto expected = (an.r1c1 * modF1) + (an.r1c2 * modF0);
					if(expected.val != xi) {
/*						writefln("a = %d, b = %d is not possible because %d != %d", ab / 11, ab % 11, expected.val, xi); */
						possibleAbs[ab] = false;
					}
				}
			}

		}
		
		foreach(ab, pos; possibleAbs) {
			if(pos) {
				writefln("%d %d", ab / 11, ab % 11);
			}
		}
	}
}

/++
 + An unsigned integer where basic arithmetic is performed modulus a value k.
 +/
class ModUint {

	public:
	
	uint val; /// The value of the uint
	uint k;   /// All operations are done modulus this value

	/++
	 + Constructor.
	+/
	this(uint val, uint k) {
		this.k = k;
		this.val = val % k;
	}
	 
	ModUint opAdd(uint o) {
		return new ModUint((o % k) + val, k);
	}
	
	ModUint opAdd(ModUint o) {
		return new ModUint((o.val % k) + val, k);
	}
	
	ModUint opMul(uint o) {
		return new ModUint((o % k) * val, k);
	}
	
	ModUint opMul(ModUint o) {
		return new ModUint((o.val % k) * val, k);
	}
}

/++
 + Class representing the matrix A.
 +/
class A {

	public:
	
	ModUint r1c1; /// Value at row 1, column 1
	ModUint r1c2; /// Value at row 1, column 2
	ModUint r2c1; /// Value at row 2, column 1
	ModUint r2c2; /// Value at row 2, column 2
	
	/++
	 + Constructor.
	 +/
	this(uint a, uint b, uint k) {
		r1c1 = new ModUint(a, k); r1c2 = new ModUint(b, k);
		r2c1 = new ModUint(1, k); r2c2 = new ModUint(0, k);
	}
	
	this(ModUint r1c1, ModUint r1c2, ModUint r2c1, ModUint r2c2) {
		this.r1c1 = r1c1;
		this.r1c2 = r1c2;
		this.r2c1 = r2c1;
		this.r2c2 = r2c2;
	}
	
	static A identity() {
		return new A(new ModUint(1, 2), new ModUint(0, 2), new ModUint(0, 2), new ModUint(1, 2));
	}
	
	A opMul(A o) {
		return new A(
			r1c1 * o.r1c1 + r1c2 * o.r2c1,
			r1c1 * o.r1c2 + r1c2 * o.r2c2,
			r2c1 * o.r1c1 + r2c2 * o.r2c1,
			r2c1 * o.r1c2 + r2c2 * o.r2c2);
	}
	
	A opXor(uint amount) {
		if(amount == 1) {
			return this;
		} else {
			auto sqrt = (this ^ (amount / 2));
			auto val = sqrt * sqrt;
			
			if((amount % 2) == 1) {
				return val * this;
			} else {
				return val;
			}
		}
	}
	
	char[] toString() {
		return " | " ~ std.string.toString(r1c1.val) ~ " " ~ std.string.toString(r1c2.val) ~ " |\n" ~
		       " | " ~ std.string.toString(r2c1.val) ~ " " ~ std.string.toString(r2c2.val) ~ " | ";
	}
}
