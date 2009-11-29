module util.swap;

/**
 * Simple function to swap two values
 */
void swap(T)(ref T a, ref T b) {
	T tmp = a;
	a = b;
	b = tmp;
}