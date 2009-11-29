#include <math.h>
#include <stdio.h>

int main(int argc, char** argv) {

	int num_test_cases;
	scanf("%d", &num_test_cases);

	for(int i = 0; i < num_test_cases; i++) {
		int n;
		scanf("%d", &n);

		int pow = 5;
		int addend = 0;
		int res = 0;
		while((addend = n / pow) > 0) {
			res += addend;
			pow *= 5;
		}
		printf("%d\n", res);
	}

	return 0;
}
