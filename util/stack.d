module util.stack;

import std.stdio;

class Stack(T) {
	
	private:
	
	T[] internalArray;
	int len;
	
	public:
	
	this(int initialLen = 1) {
		internalArray.length = initialLen;
		len = 0;
	}
	
	this(Stack o) {
		internalArray.length = o.internalArray.length;
		internalArray[] = o.internalArray;
		len = o.len;
	}
	
	void push(T item) {
		if(internalArray.length < (len + 1)) {
			internalArray.length = (internalArray.length + 1) * 2;
		}
		internalArray[len] = item;
		len++;
	}
	
	void pushAll(T[] items) {
		foreach(item; items) {
			push(item);
		}
	}
	
	T pop() {
		T item = internalArray[len - 1];
		len--;
		return item;
	}
	
	T peek() {
		return internalArray[len - 1];
	}
	
	T head() {
		return internalArray[0];
	}
	
	int length() {
		return len;
	}
	
	bool isEmpty() {
		return len == 0;
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
	
	T itemAt(int idx) {
		return internalArray[idx];
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
