import std.stdio;

T[] permute(T)(T[] v, bool delegate(T[]) fn) {
	T[] ret;
	ret.length = v.length;
	
	void swap(int i1, int i2) {
		T t = v[i1];
		v[i1] = v[i2];
		v[i2] = t;
	}
	
	bool permuteStep(int n) {
		if(n == 1) {
			if(!fn(v)) {
				ret[] = v;
				return false;
			} else {
				return true;
			}
		} else {
			foreach(i; 0 .. n) {
				if(permuteStep(n - 1)) {
					
					if(n % 2 == 0) {
						swap(i, n - 1);
					} else {
						swap(0, n - 1);
					}
				} else {
					return false;
				}
			}
			return true;
		}
	}
	
	permuteStep!(T)(v.length);
	return ret;
}

void main()
{
	int toDrop;
	long[] solutions;
	
	bool pred(int[] digits) {
		
		int[] dropped = digits[toDrop .. $];
		
		long number = 0;
		
		foreach(digit; dropped) {
			number *= 10;
			number += digit;
		}
		
		foreach(digit; dropped) {
			if(number % digit != 0) {
				return true;
			}
		}
		
		solutions ~= number;
		
		return true;
	}
	
	for(toDrop = 1; toDrop < 9; toDrop++) {
		permute!(int)([ 9, 8, 7, 6, 5, 4, 3, 2, 1 ], &pred);
		
		if(solutions.length > 0) {
			long maxSolution = 0;
			foreach(solution; solutions) {
				if(solution > maxSolution) {
					maxSolution = solution;
				}
			}
			
			writefln("%d", maxSolution);
			break;
		}
	}
}
