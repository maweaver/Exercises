import Math.sqrt

object Problem0010
	extends Application
{
	def isPrime(n: Long): Boolean = {
		var divisor = 2l
		while(divisor * divisor <= n) {
			if(n % divisor == 0) {
				return false
			}
			
			divisor = divisor + 1
		}
		
		true
	}
	
	def nextPrime(n: Long): Long = {
		var retVal = n + 1
		while(!isPrime(retVal)) {
			retVal = retVal + 1
		}
		
		retVal
	}

	def primes(n: Long): Stream[Long] =
		Stream.cons(n, primes(nextPrime(n)))
	
	println(primes(2).takeWhile { n => n < 2000000 }.foldLeft(0l) { (sum, n) => sum + n })
}