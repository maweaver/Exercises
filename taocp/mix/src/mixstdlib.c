#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mixstdlib.h>

void mix_init() {
	mix_io_init();
}

void mix_destroy() {
	mix_io_destroy();
}

char *mix_ascii_to_str(const char *ascii) {
	static char table[] = {
		 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		 0,  0,  0,  0, 49,  0,  0, 55, 42, 43, 46, 44, 41, 45, 40, 47,
		30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 54, 53, 50, 48, 51,  0,
		52,  1,  2,  3,  4,  5,  6,  7,  8,  9, 11, 12, 13, 14, 15, 16,
		17, 18, 19, 22, 23, 24, 25, 26, 27, 28, 29,  0,  0,  0,  0,  0,
		 0,  0,  0,  0, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		21 , 0,  0, 20,  0,  0,  0,  0,  0 , 0,  0,  0,  0,  0,  0 , 0
	};

	int len = strlen(ascii);
	char *str = malloc(len * sizeof(char));

	for(int i = 0; i < len; i++) {
		str[i] = table[ascii[i]];
	}

	return str;
}

char *mix_str_to_ascii(const char *str, int len) {
	static char table[] = {
		' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 
		'H', 'I', 'd', 'J', 'K', 'L', 'M', 'N', 
		'O', 'P', 'Q', 'R', 's', 'p', 'S', 'T', 
		'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', 
		'2', '3', '4', '5', '6', '7', '8', '9', 
		'.', ',', '(', ')', '+', '-', '*', '/', 
		'=', '$', '<', '>', '@', ';', ':', '\''
	};

	char *ascii = malloc((len + 1) * sizeof(char));
	for(int i = 0; i < len; i++) {
		ascii[i] = table[str[i]];
	}
	ascii[len] = 0;

	return ascii;
}

int mix_int_to_word(int num)
{
	// Same as a C int, except that it's not sign-extended--the first bit always indicates the sign
	int word = abs(num);
	if(num < 0) {
		word |= 0x40000000;
	}

	return word;
}
