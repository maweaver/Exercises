#include <stdio.h>
#include <time.h>

/*!
 *  Calculates the date of Mardis Gras for the given year.  Mardis Gras is 47
 *  days before Easter, which is the first Sunday after the first full moon on
 *  or after March 21.
 *
 *  \param   year   Year to calculate the date for, >= 1582 (when the gregorian
 *                    calendar was introduced, along with the current method
 *                    of determining Easter.
 *  \return  A structure containing the date.  Only the \c tm_year, \c tm_mon,
 *             and \c tm_mday fields are valid in this structure.
 */
struct tm mardigras(int year)
{
	struct tm ret;
	int cur_year = 1700;
	int epact_modifier = 1;
	int golden_number, epact;
	int march_twenty_doy = 0;
	int lunar_month_len = 30;
	
	/* Adjustments must be made to the epact for leap years, both lunar and 
	   solar.  However, normally these cancel each other out, as both occur
		 every 4 years.  For century years though, the rules for the lunar and
		 solar equations are different. Epacts must be adjusted for each century
		 starting with the seventeeth up until the century containing the year
		 in question.*/
	while(cur_year < year) {
		if(cur_year >= 1800 && (cur_year - 1800) % 300 == 0) {
			epact_modifier++;
		}
			
		if(cur_year % 400 != 0) {
			epact_modifier--;
		}
		
		cur_year += 100;
	}
	
	fprintf(stderr, "Epact modifier for the %d00s: %d\n", year / 100, epact_modifier);
	
	/* Calculate the golden number of the year and the epact from it */
	golden_number = (year % 19) + 1;
	epact = ((golden_number - 1) * 11) % 30 + epact_modifier;
	fprintf(stderr, "Golden Number/Epact: %d[%d]\n", golden_number, epact);
	
	/* Figure out which day of the year March 20 is.  Depends on whether this is
	   a leap year. */
	march_twenty_doy = 31 /* jan */ + 28 /* feb */ + 20 /* mar */ - 1 /* 0-based */;
	if(year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
		march_twenty_doy++;
	}
	fprintf(stderr, "March 20 is the %dth day of the year\n", march_twenty_doy);
	
	/* Find the lunar month whose full moon is after March 20 */
	ret.tm_yday = 30 - epact;
	lunar_month_len = 29;
	while(ret.tm_yday + 14 <= march_twenty_doy) {
		ret.tm_yday += lunar_month_len;
		if(lunar_month_len == 30) {
			lunar_month_len = 29;
		} else {
			lunar_month_len = 30;
		}
	}
	ret.tm_yday += 14;
	
	/* Find the day of the week of the full moon */
	ret.tm_wday = 
		(2 * (3 - (year / 100) % 4) +
		 year % 100 + ((year % 100) / 4) +
		 ret.tm_yday) % 7;
		
	fprintf(stderr, "Paschal moon is on the %dth day of the year (day of week number %d)\n", ret.tm_yday, ret.tm_wday);
	
	/* Find the following Sunday */
	ret.tm_yday += 6 - ret.tm_wday;
	ret.tm_wday = 0;
	
	fprintf(stderr, "Easter is the %dth day of the year\n", ret.tm_yday);
	
	/* Mardis Gras is 47 days before that */
	
	ret.tm_yday -= 47;
	
	fprintf(stderr, "Mardis Gras is the %dth day of the year\n", ret.tm_yday);
	
	
	/* Fill out the return structure */
	ret.tm_mday = ret.tm_yday;
	ret.tm_mon = 0;

	/* jan */
	if(ret.tm_mon == 0 && ret.tm_mday >= 31) {
		ret.tm_mon++;
		ret.tm_mday -= 31;
	}
	
	/* feb */
	if(year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
		if(ret.tm_mon == 1 && ret.tm_mday >= 29) {
			ret.tm_mon++;
			ret.tm_mday -= 29;
		}
	} else {
		if(ret.tm_mon == 1 && ret.tm_mday >= 28) {
			ret.tm_mon++;
			ret.tm_mday -= 28;
		}
	}
	
	/* mar */
	if(ret.tm_mon == 2 && ret.tm_mday >= 31) {
		ret.tm_mon++;
		ret.tm_mday -= 31;
	}
	
	/* apr */
	if(ret.tm_mon == 3 && ret.tm_mday >= 30) {
		ret.tm_mon++;
		ret.tm_mday -= 30;
	}
	
	ret.tm_mday++; /* Make ordinal */
	
	ret.tm_year = year;
	return ret;
}

int main(int argc, char **argv)
{
	struct tm ret = mardigras(2049);
	printf("%02d/%02d/%4d\n", ret.tm_mon + 1, ret.tm_mday, ret.tm_year);
}
