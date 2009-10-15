#include <stdio.h>

int month_lens[] = { 
  31 /* jan */, 28 /* feb */, 31 /* mar */, 30 /* apr */, 
  31 /* may */, 30 /* jun */, 31 /* jul */, 31 /* aug */, 
  30 /* sep */, 31 /* oct */, 30 /* nov */, 31 /* dec */ 
};
	
int get_month_len(int month, int year) {
	if(month != 1) {
		return month_lens[month];
	} else {
		return month_lens[month] + (year % 4 == 0 ? 1 : 0);
	}
}

int main(int argc, char **argv) {
	int month_num    =    2;
	int day_of_month =   12;
	int year_num     = 2009;
	int num_fri_13s  =    0;
	
	while(year_num < 2019) {
		day_of_month += 7;
		int month_len = get_month_len(month_num, year_num);
		if(day_of_month > month_len) {
			day_of_month %= month_len;
			month_num++;
			if(month_num > 11) {
				month_num = 0;
				year_num++;
			}
		}
		
		if(day_of_month == 12) {
			printf("%d/13/%d\n", month_num + 1, year_num);
			num_fri_13s++;
		}
	}
	
	printf("%d\n", num_fri_13s);
	
	return 0;
}
