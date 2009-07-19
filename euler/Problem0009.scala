object Problem0009
{
	def main(args: Array[String]) {
		for(a <- 1 to 1000; b <- a to 1000; c <- b to 1000) {
			if((a * a + b * b == c * c) && (a + b + c == 1000)) {
				println(a + "^2 + " + b + "^2 = " + c + "^2; abc = " + (a * b * c))
				return
			}
		}
	}
}