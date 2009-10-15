/*!
 *  \file   pi.c
 *  \brief  Calculates the nth digit of pi
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

/*!
 * \brief Calculate prime numbers up to a given limit
 *
 * Returns an array of all primes up to a given value.  Works by using the
 * sieve of Erastothenes.  Start with the assumption that 2 is prime.  Cross
 * out all multiples of this value.  The next number not crossed out is a prime,
 * and so it is added to the list.  Multiples of this number are crossed out,
 * and the cycle repeats.
 *
 * This method maintains a static list of primes and a static sieve, along with
 * a high water mark of the \a to parameter.  If it is called again with \a to
 * less than the high water mark, cached results are returned.  If \a to is
 * higher than this mark, then all values between the high water mark and \a to
 * are sieved using the process above (with the modification that it must 
 * restart sieving at the beginning).  
 *
 * \param   to      All primes \f$ p \le to \f$ are returned
 * \param   count   Out parameter for the number of primes found
 *
 * \return  Array of prime integers
 */
static long* calc_primes(long to, size_t *count)
{
	long                   i, j;

	const int              primes_growth_rate = 2;      /* How fast to grow the primes array */
	const int              primes_start_size  = 100;    /* How many primes to allocate initially */
	
	static long            high_water_mark    = 0;      /* Maximum value of the \a to arg */
	static size_t          num_primes         = 0;      /* Number of primes found */
	static int             primes_alloced     = 0;      /* Amount of space in the primes array */
	static long           *primes             = NULL;   /* Array of prime numbers */
	static char           *sieve              = NULL;   /* Sieve; 1 => composite */
	
	/* First call */
	if(high_water_mark == 0) {
		/* Alloc the memory */
		sieve = malloc(to * sizeof(char));
		memset(sieve, 0, to * sizeof(char));
		primes = malloc(primes_start_size * sizeof(long));
		primes_alloced = primes_start_size;
		
		/* Prime the system (hehe) */
		sieve[0]        = 1;
		primes[0]       = 2;
		high_water_mark = 2;
		num_primes      = 1;
	}
	
	if(to <= high_water_mark) {
		/* Find the number of primes <= to */
		/* TODO: Better search algorithm */
		if(count) {
			*count = 0;
			
			for(i = num_primes - 1; i >= 0; i--) {
				if(primes[i] <= to) {
					*count = i + 1;
					break;
				}
			}
		}
		
		return primes;
	} else {
		/* Allocate some extra memory for the sieve */
		sieve = realloc(sieve, to * sizeof(char));
		memset(sieve + high_water_mark, 0, (to - high_water_mark) * sizeof(char));
		
		/* Divide all the values above the high water mark by all primes below
		   the high water mark */
		for(i = high_water_mark; i < to; i++) {
			for(j = 0; j < num_primes; j++) {
				if((i + 1) % primes[j] == 0) {
					sieve[i] = 1;
				}
			}
		}
		
		/* Now continue as a normal sieve--find the first 0, mark it prime, divide
		   the rest of the sieve by it, and continue until we hit to */
		for(i = high_water_mark; i < to; i++) {
			if(!sieve[i]) {
				if(primes_alloced <= num_primes) {
					primes_alloced *= primes_growth_rate;
					primes = realloc(primes, primes_alloced * sizeof(long));
				}
				primes[num_primes] = i + 1;
				num_primes++;

				for(j = i + 1; j < to; j++) {
					if(((j + 1) % (i + 1)) == 0) {
						sieve[j] = 1;
					}
				}
			}
		}
		
		high_water_mark = to;
		
		if(count) {
			*count = num_primes;
		}
		return primes;
	}
}

/*!
 *  \brief Factor of an integer
 *
 *  A single factor of an integer.  Stored as a linked list so that factors can
 *  easily be added as found and also be easily iterated
 */
struct factor {
	long   value;  /*!< Value of this factor         */
	struct factor  *next;   /*!< Next factor, or NULL if none */
};

/*!
 *  Frees the memory used by a list of factors
 *
 *  \param   factors   Factors to free
 */
static void free_factors(struct factor *factors)
{
	struct factor *prev = NULL;
	struct factor *cur  = NULL;
	
	cur = factors;
	while(cur) {
		prev = cur;
		cur = cur->next;
		free(prev);
	}
}

/*!
 *  Calculates all the prime factors of the given value.  Does this in a 
 *  simplistic manner, using trial division on all values below the sqrt(n).
 *
 *  \param   n   Value to factorize
 *
 *  \return  List of factors
 */
static struct factor *calc_prime_factors(long n, long max_factor, size_t *num_factors)
{
	long i;
	
	struct factor   *ret = NULL;
	struct factor   *tail = NULL;
	long            *primes;
	size_t           num_primes;
	
	primes = calc_primes(max_factor, &num_primes);
	*num_factors = 0;
	
	if(max_factor == 0) {
		return ret;
	}
	
	for(i = 0; i < num_primes; i++) {
		if(n % primes[i] == 0) {
			*num_factors = *num_factors + 1;
			if(!tail) {
				ret = malloc(sizeof(struct factor));
				tail = ret;
			} else {
				tail->next = malloc(sizeof(struct factor));
				tail = tail->next;
			}
			tail->value = primes[i];
			tail->next = NULL;
		}
	}
	
	if(!ret && n <= max_factor) {
		*num_factors = 1;
		ret = malloc(sizeof(struct factor));
		ret->value = n;
		ret->next = NULL;
	}
	
	return ret;
}

/*!
 *  Calculates \f$ b^e \bmod m \f$
 *
 *  \param   b   Base
 *  \param   e   Exponent
 *  \param   m   Modulus
 */
__attribute__((const))
static long expt_mod(long b, long e, long m)
{
	long ret = 1;
	
	while(e > 0) {
		if(e & 1) {
			ret = (ret * b) % m;
		}
		
		e >>= 1;
		b = (b * b) % m;
	}
	
	return ret;
}

/*!
 *  Calculates \f$ n \bmod m \f$.  Works properly for negative values.
 *
 *  \param   n   Value
 *  \param   m   Modulus
 */
__attribute__((const))
static inline long int_modulus(long n, long m)
{
	long res;
	res = n - m * (n / m);
	if(res < 0) {
		res += m;
	}
	
	return res;
}

/*!
 *  Calculates \f$ (a \cdot b) \bmod m \f$
 *
 *  \param   a   First multiplicand
 *  \param   b   Second multiplicand
 *  \param   m   Modulus
 */
__attribute__((const))
static inline long mod_mul(long a, long b, long m)
{
	return a * b - (long) ((1.0 / (double) m) * (double) a * (double) b) * m;
}

/*!
 *  Calculates the modular multiplicative of \a n with respect to modulo \a m.
 *  That is to say, it calculates a number \a x such that
 *  \f$ nx = 1 \pmod {m} \f$.
 *
 *  Uses the extended Euclidean algorithm to do the calculation.
 *
 *  \param   n   Number to invert
 *  \param   m   Modulus
 *
 *  \return  Multiplicative inverse of n mod m
 */
__attribute__((const))
static long mod_inv(long n, long m)
{
	long      x = 0;
	long prev_x = 1;
	long      y = 1;
	long prev_y = 0;
	
	long q = 0;
	long tmp;
	
	while(m) {
		q = n / m;
		
		tmp = m;
		m = int_modulus(n, m);
		n = tmp;
		
		tmp = x;
		x = prev_x - q * x;
		prev_x = tmp;
		
		tmp = y;
		y = prev_y - q * y;
		prev_y = tmp;
	}
	
	return prev_x;
}

/*!
 *  Calculates \f$ \sum_{j=0}^k{binom(n, j)} \bmod m \f$ where binom is the
 *  binomial coefficient of n and j.
 *
 *  \param   k   Summation upper limit
 *  \param   n   Upper term of binomial coefficient
 *  \param   m   Modulus
 */
__attribute__((const, hot))
static long mod_sum_binom(long k, long n, long m)
{
	long j;
	long A, B, C, C_acc;
	long a, b, a_star, b_star;
	
	size_t         num_factors_m;
	struct factor *prime_factors_m;
	struct factor *cur_fact;
	
	struct factor *r      = NULL;
	struct factor *cur_r  = NULL;
	
	if(k > n / 2) {
		return int_modulus(expt_mod(2, n, m) - mod_sum_binom(n - k - 1, n, m), m);
	}
	
	/* Step 1 */
	prime_factors_m = calc_prime_factors(m, k, &num_factors_m);
	
	/* Step 2 */
	A = 1; B = 1; C = 1;
	
	for(j = 0; j < num_factors_m; j++) {
		if(!cur_r) {
			r = malloc(sizeof(struct factor));
			cur_r = r;
		} else {
			cur_r->next = malloc(sizeof(struct factor));
			cur_r = cur_r->next;
		}
		cur_r->value = 1;
		cur_r->next = NULL;
	}
	
	for(j = 1; j <= k; j++) {
		
		/* Step 3a */
		a = n - j + 1;
		b = j;
		
		/* Steps 3b and 3c */
		cur_fact = prime_factors_m;
		cur_r = r;
		a_star = a;
		b_star = b;
		while(cur_fact) {
			while(a_star % cur_fact->value == 0) {
				a_star /= cur_fact->value;
				cur_r->value *= cur_fact->value;
			}
			
			while(b_star % cur_fact->value == 0) {
				b_star /= cur_fact->value;
				cur_r->value /= cur_fact->value;
			}
			
			cur_fact = cur_fact->next;
			cur_r = cur_r->next;
		}
		
		/* Step 3d */
		A = mod_mul(A, a_star, m);
		B = mod_mul(B, b_star, m);
	
		C = mod_mul(C, b_star, m);
	
		C_acc = A;
		for(cur_r = r; cur_r; cur_r = cur_r ->next) {
			C_acc = mod_mul(C_acc, cur_r->value, m);
		}
		
		C = int_modulus(C + C_acc, m);
	}
	
	free_factors(prime_factors_m);
	free_factors(r);
	
	/* Step 4 */
	return mod_mul(C, mod_inv(B, m), m);
}

/*!
 *  Gets \a n0 digits of \f$ \pi \f$ starting with digit \a n.  The first digit after the decimal point is
 *  digit 0.  Because the digits are returned in a double, the number of digits in the result cannot be higher
 *  than the precision of a double, regardless of n0.
 *
 *  This method only returns accurate results when \f$ n \ge 4 \cdot n0 \f$.
 *
 *  \param   n   Offset of digit to retrieve
 *  \param   n0  Number of digits to retrieve; also the precision of the result
 *
 *  \return  A decimal number whose integer part is 0 and whose decimal part corresponds to the nth digit of
 *           pi.  Another way to put it is, this is the decimal part of \f$ \pi \cdot 10^n \f$ , accurate to
 *           \a n0 decimal places.
 */
double get_pi_digits(long n, long n0)
{
	long k;
	long M, N, m, s;
	double b, c, x, t;
	int sign;
	double log_n;
	
	log_n = log(n);
	
	M = 2 * (long) (3 * n / log_n / log_n / log_n);
	N = (long) ((n + n0 + 1) * (log(10) / (log(2 * M_E * M)))) + 1;
	N += N % 2;
	
	b = 0;	
	for(k = 0; k < (M + 1) * N; k += 2) {
		x = 0;
		
		m = 2 * k + 1;
		s = expt_mod(10, n, m);
		s = mod_mul(4, s, m);
		x += (double) s / (double) m;
		
		m = 2 * k + 3;
		s = expt_mod(10, n, m);
		s = mod_mul(4, s, m);
		x -= (double) s / (double) m;
		
		b += x;
		if(b <= -0.5) {
			b += 1;
		} else if(b >= 1) {
			b -= 2;
		}
	}
	
	c = 0;
	sign = -1;
	for(k = 0; k < N; k++) {
		m = 2 * M * N + 2 * k + 1;
		s = mod_sum_binom(k, N, m);
		s = mod_mul(s, expt_mod(5, N, m), m);
		s = mod_mul(s, expt_mod(10, n - N, m), m);
		s = mod_mul(4, s, m);
		b += sign * (double) s / (double) m;
		b = b - floor(b);

		sign = -sign;
	}
	
	return modf(b, &t);
}

/*!
 *  Returns the nth decimal digit of \f$ \pi \f$.  Uses get_pi_digits() under the cover, but provides a nicer 
 *  API for getting a single digit.
 *
 *  \param   n  Offset of digit to retrieve
 *  \return  The given digit
 *  
 */
int get_pi_digit(long n) {
	const int initial_digits[] = { 
		1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 
		8, 9, 7, 9, 3, 2, 3, 8, 4, 6, 
		2, 6, 4, 3, 3, 8, 3, 2, 7, 9, 
		5, 0, 2, 8, 8, 4, 1, 9, 7, 1, 
		6, 9, 3, 9, 9, 3, 7, 5, 1, 0 };
	
	if(n < 50) {
		return initial_digits[n];
	} else {
		return (int) (10 * get_pi_digits(n, 14));
	}
}

static void print_digits(FILE *stream, long n, int num_digits) {
	int i;
	double t, val;
	
	val = get_pi_digits(n, num_digits);
	
	for(i = 0; i < num_digits; i++) {
		val *= 10;
		fprintf(stream, "%d", (int) val);
		val = modf(val, &t);
	}
}

int main(int argc, char **argv)
{
	long n;
	long N = 2000;
	double pct = 0;
	int last_pct = -1;
	FILE *out;
	
	out = fopen("pi.out", "w");

	fprintf(out, "3.\n");
	for(n = 0; n < 50; n++) {
		fprintf(out, "%d", get_pi_digit(n));
	}
	fprintf(out, "\n");
	
	for(n = 50; n < N; n += 10) {
		pct = (double) n / (double) N;
		if(floor(pct * 100) > last_pct) {
			fprintf(stderr, "\r%d%%", (int) (pct * 100));
			last_pct++;
		}
		print_digits(out, n, 10);
		if(n != 0 && (n + 10) % 50 == 0) {
			fprintf(out, "\n");
		}
	}
	fprintf(stderr, "\r100%%\n");
	fprintf(out, "\n");
	
	fclose(out);
}
