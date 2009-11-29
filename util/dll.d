module util.dll;

import std.stdio;

/++
 + A node in the linked list
 +/
class LinkedListNode(T) {

	/++
	 + Constructor
	 +/
	this(T value, LinkedListNode!(T) next, LinkedListNode!(T) prev) {
		this.value = value;
		this.next = next;
		this.prev = prev;
	}

	T value;
	
	LinkedListNode!(T) next;
	LinkedListNode!(T) prev;
}

/++
 + A doubly-linked list, with references to the head and tail elements.  Supports constant-time access to the
 + end elements, and linear access to other elements.
 +/
class LinkedList(T) {
	
	public:
	
	LinkedListNode!(T) head;    /// The head node
	LinkedListNode!(T) tail;    /// The tail node
	
	int length;        /// The number of elements in this list

	/++
	 + Constructor.
	 +/
	this() {
		length = 0;
		head = null;
		tail = null;
	}

	this(T[] initialValues) {
		length = 0;
		head = null;
		tail = null;
		foreach(v; initialValues) {
			pushTail(v);
		}
	}
	
	/++
	 + Pushes a value onto the right side of the buffer
	 +/
	void pushTail(T value) {
		tail = new LinkedListNode!(T)(value, null, tail);
		if(!head) {
			head = tail;
		}
		if(tail.prev) {
			tail.prev.next = tail;
		}
		length++;
	}
	
	/++
   + Operator version of pushItemR
	 +/
	LinkedList!(T) opCat(T value) {
		pushTail(value);
		return this;
	}
	
	/++
	 + Operator version of pushR
	 +/
	void opCatAssign(T value) {
		pushTail(value);
	}
	
	/++
	 + Pushes a value onto the left side of the list
	 +/
	void pushHead(T value) {
		head = new LinkedListNode!(T)(value, head, null);
		if(!tail) {
			tail = head;
		}
		if(head.next) {
			head.next.prev = head;
		}
		length++;
	}
	
	/++
	 + Operator version of pushL
	 +/
	LinkedList!(T) opCat_r(T value) {
		pushHead(value);
		return this;
	}
	
	/++
	 + Removes the first element in the list and returns it
	 +/
	T popHead() {
		if(head) {
			auto oldHead = head;
			head = head.next;
			if(head) {
				head.prev = null;
			}
			length--;
			return oldHead.value;
		} else {
			throw new Exception("Attempted to popHead() from an empty list!");
		}
	}
	
	/++
	 + Returns the first element in the list without removing it
	 +/
	T peekHead() {
		if(head) {
			return head.value;
		} else {
			throw new Exception("Attempted to peekHead() from an empty list!");
		}
	}
	
	/++
	 + Removes the last element in the list and returns it
	 +/
	 T popTail() {
	 	 if(tail) {
	 	 	 auto oldTail = tail;
	 	 	 tail = tail.prev;
	 	 	 if(tail) {
	 	 	 	 tail.next = null;
	 	 	 }
	 	 	 length--;
	 	 	 return oldTail.value;
	 	 } else {
	 	 	 throw new Exception("Attempted to popTail() from an empty list!");
	 	 }
	 }
	
	/++
	 + Converts this digit to an array
	 +/
	T[] toArray() {
		auto res = new T[length];
		for(auto node = head, idx = 0;
			node && idx < length;
			node = node.next, idx++) {

			res[idx] = node.value;
		}
		
		return res;
	}
	
	/++
	 + Operator version of toArray
	 +/
	T[] opCast() {
		return toArray();
	}
	
	/++
	 + Pop the last element and discard it
	 +/
	void opPostDec() {
		popTail();
	}
	
	/++
	 + True if the list contains the given value; does a simple linear search
	 +/
	bool opIn_r(T value) {
		foreach(elem; this) {
			if(elem == value) {
				return true;
			}
		}
		
		return false;
	}
	
	/++
	 + Foreach support
	 +/
	int opApply(int delegate(ref T) dg) {
		int result = 0;
		auto node = head;
		
		while(node) {
			result = dg(node.value);
			if(result) {
				break;
			}
			node = node.next;
		}
		
		return result;
	}
	
	/++
	 + Reverse foreach support
	 +/
	int opApplyReverse(int delegate(ref T) dg) {
		int result = 0;
		auto node = tail;
		
		while(node) {
			result = dg(node.value);
			if(result) {
				break;
			}
			node = node.prev;
		}
		
		return result;
	}
	
	/++
	 + Random access in O(n) time
	 +/
	T opIndex(size_t i) {
		auto node = head;
		while(node && i > 0) {
			node = node.next;
			i--;
		}
		if(node) {
			return node.value;
		} else {
			throw new Exception("Index out of range");
		}
	}
	
	/++
	 + Compares with another list by linearly comparing each element
	 +/
	bool opEquals(Object o) {
		auto other = cast(LinkedList!(T)) o;
		if(other && other.length == length) {
			auto thisNode = head;
			auto otherNode = other.head;
			while(thisNode && otherNode) {
				if(thisNode.value != otherNode.value) {
					return false;
				}
				thisNode = thisNode.next;
				otherNode = otherNode.next;
			}
			if(thisNode || otherNode) {
				return false;
			} else {
				return true;
			}
		} else {
			return false;
		}
	}
	
	/++
	 + True if the list is empty, false otherwise
	 +/
	bool isEmpty() {
		return length == 0;
	}
	
	/++
	 + Removes all elements past the given index from this list, and return a new list containing only those
	 + elements.
	 +/
	LinkedList!(T) splitAt(int index) {
		auto splitNode = head;
		foreach(i; 0 .. index) {
			if(!splitNode) {
				throw new Exception("Index out of range");
			}
			
			splitNode = splitNode.next;
		}
		
		auto newList = new LinkedList!(T)();
		newList.head = splitNode.next;
		newList.tail = tail;
		tail = splitNode;
		splitNode.next.prev = null;
		splitNode.next = null;
		newList.length = length - index - 1;
		length = index + 1;
		return newList;
	}
	
	/++
	 +  Removes the first node whose data value is equal to T
	 +/
	void remove(T value) {
		auto node = head;
		while(node) {
			if(node.value == value) {
				node.prev.next = node.next;
				node.next.prev = node.prev;
				break;
			}
			node = node.next;
		}
	}
	
	/++
	 +  Removes all nodes
	 +/
	void clear() {
		head = null;
		tail = null;
	}

	/++
	 +  Creates a new linked list by duplicating this one
	 +/
	LinkedList!(T) dup() {
		auto newList = new LinkedList!(T)();
		auto node = head;
		while(node) {
			newList.pushTail(node.value);
			node = node.next;
		}
		return newList;
	}
	
	unittest {
		auto test = new LinkedList!(int)();
		
		writefln("Empty digit has length 0");
		assert(test.length == 0);
		
		writefln("After pushing has length 1");
		test.pushTail(1);
		assert(test.length == 1);
		
		writefln("After pushing again has length 2");
		test = test ~ 2;
		assert(test.length == 2);
		
		writefln("After pushing again has length 3");
		test ~= 3;
		assert(test.length == 3);
		
		writefln("After pushing to the front has length 4");
		test = 4 ~ test;
		assert(test.length == 4);
		
		writefln("After pushing to the front has length 5");
		test.pushHead(5);
		assert(test.length == 5);

		writefln("Calling toArray() == [5, 4, 1, 2, 3]");
		auto testArr = cast(int[]) test;
		assert(testArr.length == 5);
		assert(testArr[0] == 5);
		assert(testArr[1] == 4);
		assert(testArr[2] == 1);
		assert(testArr[3] == 2);
		assert(testArr[4] == 3);
		
		writefln("Foreach...");
		auto idx = 0;
		foreach(elem; test) {
			writefln("For idx %d, %d vs %d", idx, elem, testArr[idx]);
			assert(elem == testArr[idx++]);
		}
		
		writefln("Foreach reverse...");
		idx = 4;
		foreach_reverse(elem; test) {
			writefln("For idx %d, %d vs %d", idx, elem, testArr[idx]);
			assert(elem == testArr[idx--]);
		}

		writefln("popHead() returns 5, length == 4");
		auto val = test.popHead();
		assert(val == 5);
		assert(test.length == 4);
		
		writefln("peekHead() == 4");
		assert(test.peekHead() == 4);
		
		writefln("popTail() returns 3, length == 3");
		val = test.popTail();
		assert(val == 3);
		assert(test.length == 3);
		
		writefln("test--.length == 2");
		test--;
		assert(test.length == 2);
		
		writefln("2 in test");
		assert(4 in test);
		
		writefln("3 !in test");
		assert(!(3 in test));
		
		writefln("test[1] == 1");
		assert(test[1] == 1);
		
		writefln("==");
		auto test2 = new LinkedList!(int)();
		assert(test != test2);
		test2 = test2 ~ 4 ~ 1;
		assert(test == test2);
		
		writefln("isEmpty()");
		assert(!test.isEmpty);
		test--;
		test--;
		assert(test.isEmpty);
		assert(test != test2);
		
		writefln("Split!");
		test = new LinkedList!(int)();
		test = test ~ 1 ~ 2 ~ 3 ~ 4 ~ 5;
		test2 = test.splitAt(2);
		assert(test.length == 3);
		assert(test2.length == 2);
		testArr = test.toArray;
		assert(testArr.length == 3);
		assert(testArr[0] == 1);
		assert(testArr[1] == 2);
		assert(testArr[2] == 3);
		testArr = test2.toArray;
		assert(testArr.length == 2);
		assert(testArr[0] == 4);
		assert(testArr[1] == 5);
	}
}
/*
void main() {
	auto ref1 = new LinkedList!(int)();
}*/
