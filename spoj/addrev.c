#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*!
 *  Performs an in-place reversal of the given string
 */
void inplace_reverse(char *str) {
	char *a = str;
	char *b = str + strlen(str) - 1;
	while(a < b) {
		char tmp = *a;
		*(a++) = *b;
		*(b--) = tmp;
	}
}

/*!
 *  Strips leading zeros off a string number
 */
char *strip_zeros(char *num) {
	while(*num == '0') {
		num++;
	}
	return num;
}

/*!
 *  Adds two numbers in string representation
 */
char *add(char *a, char *b) {
	int   len_a = strlen(a),      len_b = strlen(b);
	char *p_a   = a + len_a - 1, *p_b   = b + len_b - 1;

	int   len_res = (len_a > len_b ? len_a : len_b) + 1;
	char *res = malloc(len_res * sizeof(char)), *p_res = res + len_res;

	*(p_res--) = 0;

	int overflow = 0;
	for(int i = 0; i < len_res - 1; i++) {
		int num_1 = p_a >= a ? (*(p_a--) - '0') : 0;
		int num_2 = p_b >= b ? (*(p_b--) - '0') : 0;
		
		int full_res = num_1 + num_2 + overflow;
		int digit = full_res % 10;
		overflow = full_res / 10;
		
		*(res--) = digit + '0';
	}

	if(overflow) {
		*res = overflow + '0';
	} else {
		res++;
	}

	return res;
}

void test_reverse() {
	char test[] = "ABC";
	inplace_reverse(test);
	assert(strcmp(test, "CBA") == 0);
}

void test_strip() {
	char test[] = "00123";
	char *stripped_test = strip_zeros(test);
	assert(strcmp(stripped_test, "123") == 0);
}

void test_add() {
	char test1[] = "123";
	char test2[] = "456";
	char test3[] = "999";
	char test4[] = "9";

	char *res1 = add(test1, test2);
	printf("123 + 456 = %s [579]\n", res1);
	assert(strcmp(res1, "579") == 0);
	
	char *res2 = add(test1, test3);
	printf("123 + 999 = %s [1122]\n", res2);
	assert(strcmp(res2, "1122") == 0);

	char *res3 = add(test1, test4);
	printf("123 + 9 = %s [132]\n", res3);
	assert(strcmp(res3, "132") == 0);

	char *res4 = add(test3, test4);
	printf("9 + 999 = %s [1008]\n", res4);
	assert(strcmp(res4, "1008") == 0);
}

int main(int argc, char **argv) {
	/*
   	test_reverse();
	test_strip();
	test_add();
	*/

	int num_test_cases;
	scanf("%d", &num_test_cases);

	for(int i = 0; i < num_test_cases; i++) {
		char num_1[100], num_2[100];
		scanf("%s %s", num_1, num_2);

		inplace_reverse(num_1);
		inplace_reverse(num_2);

		char *res = add(num_1, num_2);
		
		inplace_reverse(res);
		res = strip_zeros(res);
		
		printf("%s\n", res);
	}
	return 0;
}
