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

void main() {
	const int B = 0, C = 1, F = 2, M = 3, S = 4;
	
	bool pred(int[] floors) {
		return
			floors[B] == 5 ||
			floors[C] == 1 ||
			floors[F] == 1 || floors[F] == 5 ||
			floors[M] < floors[C] ||
			floors[S] == floors[F] + 1 || floors[S] == floors[F] - 1 ||
			floors[F] == floors[C] + 1 || floors[F] == floors[C] - 1;
	}
	
	int[] solution = permute!(int)([1, 2, 3, 4, 5], &pred);
	
	auto names = [ "Baker", "Cooper", "Fletcher", "Miller", "Smith" ];
	foreach(i, s; solution) {
		writefln("%10s lives on floor %d", names[i], s);
	}
}
