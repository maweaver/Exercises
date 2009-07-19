object Problem0020
	extends Application
{
	def fac(n: BigInt): BigInt = {
		if(n < 2) {
			n
		} else {
			n * fac(n - 1)
		}
	}
	
	println(fac(100).toString.toList.map { c => c.asDigit }.foldLeft(0) { (sum, n) => sum + n })
}