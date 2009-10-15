#include <assert.h>
#include <stdio.h>

int int_compare(void *ap, void *bp) {
	int a = *((int *) ap);
	int b = *((int *) bp);
	
	if(a < b) {
		return -1;
	} else if(a == b) {
		return 0;
	} else {
		return 1;
	}
}

int bsearch(void *arr, int elem_size, int offset, int len, void *value, int (fn)(void *, void *)) {
	if(len == 1) {
		if(fn(arr, value) != 0) {
			return -1;
		} else {
			return offset;
		}
	} else {
		int pivot_off = len / 2;
		void *pivot_val = arr + elem_size * (offset + pivot_off);
		int pivot_cmp = fn(value, pivot_val);
		if(pivot_cmp == 0) {
			return offset + pivot_off;
		} else if(pivot_cmp < 0) {
			return bsearch(arr, elem_size, offset, pivot_off, value, fn);
		} else /*if(pivot_cmp > 0)*/ {
			return bsearch(arr, elem_size, offset + pivot_off, len - pivot_off, value, fn);
		}
	}
}

int main(int argc, char **argv) {
	int one = 1, two = 2, three = 3, five = 5, nine = 9, thirteen = 13;
	int test_1[] = { 1 };
	int test_2[] = { 1, 3 };
	int test_3[] = { 1, 2, 2, 3 };
	int test_4[] = { 1, 3, 5, 9, 13 };
	
	assert(bsearch(test_1, sizeof(int), 0, 1, &one, &int_compare) == 0);

	assert(bsearch(test_2, sizeof(int), 0, 2, &one, &int_compare) == 0);
	assert(bsearch(test_2, sizeof(int), 0, 2, &two, &int_compare) == -1);
	assert(bsearch(test_2, sizeof(int), 0, 2, &three, &int_compare) == 1);
	
	assert(bsearch(test_3, sizeof(int), 0, 4, &one, &int_compare) == 0);
	assert(bsearch(test_3, sizeof(int), 0, 4, &two, &int_compare) == 2);
	assert(bsearch(test_3, sizeof(int), 0, 4, &three, &int_compare) == 3);
	
	assert(bsearch(test_4, sizeof(int), 0, 5, &one, &int_compare) == 0);
	assert(bsearch(test_4, sizeof(int), 0, 5, &three, &int_compare) == 1);
	assert(bsearch(test_4, sizeof(int), 0, 5, &five, &int_compare) == 2);
	assert(bsearch(test_4, sizeof(int), 0, 5, &nine, &int_compare) == 3);
	assert(bsearch(test_4, sizeof(int), 0, 5, &thirteen, &int_compare) == 4);
	assert(bsearch(test_4, sizeof(int), 0, 5, &two, &int_compare) == -1);
	
	return 0;
}
