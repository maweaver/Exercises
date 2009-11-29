#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char accounts[100000][34];

int account_cmp(const void *pa, const void *pb) {
	const char *a = (const char *) pa;
	const char *b = (const char *) pb;

	return strcmp(a, b);
}

int main(int argc, char** argv) {
	int num_test_cases;
	scanf("%d", &num_test_cases);

	for(int i = 0; i < num_test_cases; i++) {
		int num_accounts;
		scanf("%d", &num_accounts);

		fgets(accounts[0], 34, stdin);
		for(int j = 0; j < num_accounts; j++) {
			fgets(accounts[j], 34, stdin);
			accounts[j][31] = 0;
		}
		
		qsort(accounts, num_accounts, 34, &account_cmp);

		for(int j = 0; j < num_accounts; j++) {
			int count = 1;
			while(j + 1 < num_accounts && strcmp(accounts[j], accounts[j + 1]) == 0) {
				j++;
				count++;
			}

			printf("%s %d\n", accounts[j], count);
		}
		printf("\n");
	}

	return 0;
}
