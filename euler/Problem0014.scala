import scala.collection.mutable.HashMap

import Math.max

object Problem0014
	extends Application
{
	def series(n: Long): Stream[Long] =
		Stream.cons(n, 
			series(
				(n % 2) match {
					case 0 => n / 2l
					case 1 => 3l * n + 1l
				}
			)
		)
	
	var maxNumTerms = 0l
	var maxStarter = 0l
	var lengths = new HashMap[Long, Long]()
		
	lengths.put(1l, 1l)
	for(i <- 2 to 1000000) {
		val thisSeries = series(i).takeWhile { n => n >= i }
		lengths.put(i, thisSeries.length.toLong + lengths(series(i).take(thisSeries.length + 1).reverse.head))
		//println(i + ": " + lengths(i) + ": " + thisSeries.mkString("", ", ", ""))
		
		if(maxNumTerms < lengths(i)) {
			maxNumTerms = lengths(i)
			maxStarter = i
		}
	}
	println(maxStarter)

}