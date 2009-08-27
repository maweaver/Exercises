module util.queue;

import std.stdio;

class Queue(T) {
	
	private:
	
	T[] internalArray;
	
	public:
	
	void push(T item) {
		internalArray ~= item;
	}
	
	T pop() {
		T item = internalArray[0];
		internalArray = internalArray[1..$];
		return item;
	}
	
	T peek() {
		return internalArray[0];
	}
	
	T tail() {
		return internalArray[$-1];
	}
	
	int length() {
		return internalArray.length;
	}
	
	bool isEmpty() {
		return length == 0;
	}
	
	int indexOf(T item) {
		foreach(idx, check; internalArray) {
			if(check == item) {
				return idx;
			}
		}
		
		return -1;
	}
	
	bool contains(T item) {
		return indexOf(item) != -1;
	}
	/*
	char[] toString() {
		char[] str = "[ ";
		foreach(item; internalArray) {
			str ~= " " ~ item.toString ~ " ";
		}
		return str ~ "]";
	}
	*/
}
