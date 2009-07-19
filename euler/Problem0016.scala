object Problem0016
	extends Application
{
	def numToList(n: Int): List[Int] = n.toString.toList.map{ c => c.asDigit }
	
	def doubleLongNum(num: List[Int]): List[Int] = {
		var carry = 0
		var newNum: List[Int] = List()
		for(n <- num.reverse) {
			var newDigit = n * 2 + carry
			carry = newDigit / 10
			newDigit = newDigit % 10
			newNum = newDigit :: newNum
		}
		
		if(carry != 0) {
			newNum = carry :: newNum
		}
		
		newNum
	}
	
	def doubleStream(num: List[Int]): Stream[List[Int]] = 
		Stream.cons(num, doubleStream(doubleLongNum(num)))
	
	println(doubleStream(numToList(2)).take(1000).reverse.head.foldLeft(0) { (sum, n) => sum + n })
}