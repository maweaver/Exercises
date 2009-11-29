module util.qsort;

import std.random;
import std.stdio;

import util.swap;


/**
 * Does an in-place sort of arr using the given comparison function.  This sort is destructive and
 * unstable.
 */
void qsort(T)(T[] arr, bool delegate(T, T) comp, int left = 0, int right = -1) {
	if(right == -1) {
		right = arr.length - 1;
	}

	/**
	 *  Reorders arr[l..r] so that arr[l..<ret>] <= arr[p], and arr[<ret>..r] >= arr[p].
	 */
	int partition(T[] arr, int l, int r, int p) {
		auto pivot = arr[p];
		swap!(T)(arr[p], arr[r]);
		auto pivotIdx = l;

		for(int i = l; i < r - 1; i++) {
			if(pivot == arr[i] || comp(arr[i], pivot)) {
				swap!(T)(arr[i], arr[pivotIdx]);
				pivotIdx++;
			}
		}

		swap!(T)(arr[pivotIdx], arr[r]);

		return pivotIdx;
	}

	if(right > left) {
		auto pivotIdx = partition(arr, left, right, uniform(left, right));
		qsort!(T)(arr, comp, left, pivotIdx - 1);
		qsort!(T)(arr, comp, pivotIdx + 1, right);
	}
}