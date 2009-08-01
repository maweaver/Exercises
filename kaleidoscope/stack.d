import std.stdio;

class Stack(T) {
	
	private:
	
	T[] internalArray;
	
	public:
	
	void push(T item) {
		internalArray.length = internalArray.length + 1;
		internalArray[internalArray.length - 1] = item;
	}
	
	T pop() {
		T item = internalArray[internalArray.length - 1];
		internalArray.length = internalArray.length - 1;
		return item;
	}
	
	T peek() {
		return internalArray[internalArray.length - 1];
	}
	
	T head() {
		return internalArray[0];
	}
	
	int length() {
		return internalArray.length;
	}
}
