module util.leftheap;

import std.math;
import std.stdio;
import std.string;

/++
 + A left heap is a binary tree with two conditions:
 +
 +  - Each node has a value, and the value of each node is less than the value
 +    of each of its descendant nodes
 +
 +  - The rank of the left child of a node is greater than or equal to the rank
 +    of the right child
 +/
class LeftHeap(T) {
	private:
	
	bool _minHeap;
	LeftHeapNode!(T) root;
	
	public:
	
	/++
	 + Constructor
	 +/
	this(bool minHeap = true, LeftHeapNode!(T) root = null) {
		this.root = root;
		_minHeap = minHeap;
	}	
	
	/++
	 + Whether this is a min heap(true) or a max heap (false)
	 +/
	bool minHeap() {
		return _minHeap;
	}
	
	/++
	 + Inserts a new value into the heap
	 +/
	void insert(int value, T data) {
		// Inefficient method, but easy
		auto node = new LeftHeapNode!(T)(value, data);
		if(!root) {
			root = node;
		} else {
			root = root.merge(minHeap, node);
		}
	}
	
	/++
	 + Insert another leftheap
	 +/
	void insert(LeftHeap!(T) heap) {
		root = root.merge(minHeap, heap.root);
	}
	
	/++
	 + Removes all elements
	 +/
	void clear() {
		root = null;
	}
	
	/++
	 + Returns the next data element
	 +/
	T peek() {
		return root.data;
	}
	
	/++
	 + Returns the next value
	 +/
	int peekValue() {
		if(root) {
			return root.value;
		} else {
			return -1;
		}
	}
	
	/++
	 + Returns the next data, or null if there is none
	 +/
	T poll() {
		auto data = root.data;
		if(root.left) {
			root = root.left.merge(minHeap, root.right);
		} else {
			root = root.right;
		}
		return data;
	}
	
	/++
	 + Returns the next value, or null if there is none
	 +/
	int pollValue() {
		if(root) {
			int value = root.value;
			if(root.left) {
				root = root.left.merge(minHeap, root.right);
			} else {
				root = root.right;
			}
			return value;
		} else {
			return -1;
		}
	}

	/++
	 + True if no more elements are left
	 +/
	bool isEmpty() {
		return root is null;
	}
	
	/++
	 + Convert the data to an array
	 +/
	T[] toArray() {
		T[] ret;
		
		while(!isEmpty) {
			ret ~= poll();
		}
		
		return ret;
	}

	/++
	 + Convert the values to an array
	 +/
	int[] toValueArray() {
		int[] ret;
		
		while(!isEmpty) {
			ret ~= pollValue();
		}
		
		return ret;
	}

	/++
	 + Returns a .dot representation of the graph
	 +/
	char[] toString() {
		return "digraph G {\n" ~
		(root ? root.toString() : "\n") ~
			"}";
	}
}

/++
 + A single node in a leftist heap
 +/
class LeftHeapNode(T) {
	public:
	
	/++
	 + Constructor
	 +/
	this(int value, T data) {
		left = null;
		right = null;
		this.value = value;
		this.data = data;
		s = 1;
	}
	
	/++
	 + Left child
	 +/
	LeftHeapNode!(T) left;
	
	/++
	 + Right child
	 +/
	LeftHeapNode!(T) right;
	
	/++
	 + Value of this node
	 +/
	int value;
	
	/++
	 + Data associated with this node
	 +/
	T data;
	
	/++
	 + Shortest path to an external node in the subtree rooted by this node
	 +/
	int s;
	
	
	LeftHeapNode!(T) merge(bool minHeap, LeftHeapNode!(T) o) {
		if(!o) {
			return this;
		}
		// writefln("Merging node %d with node %d", a.value, b.value);
		LeftHeapNode!(T) upper;
		LeftHeapNode!(T) lower;
		
		if(value < o.value) {
			upper = this;
			lower = o;
		} else {
			upper = o;
			lower = this;
		}
		
		if(!minHeap) {
			auto tmp = upper;
			upper = lower;
			lower = tmp;
		}
		
		if(upper.right) {
			upper.right = upper.right.merge(minHeap, lower);
		} else {
			upper.right = lower;
		}
		
		int sleft = upper.left ? upper.left.s : 0;
		int sright = upper.right ? upper.right.s : 0;
		
		upper.s = cast(int) fmin(sleft, sright) + 1;
		
		if(sleft < sright) {
			auto tmp = upper.left;
			upper.left = upper.right;
			upper.right = tmp;
		}
			
		return upper;
	}
	
	char[] toString() {
		auto str = std.string.toString(toHash) ~ " [label=\"" ~ std.string.toString(value) ~ ":" ~ std.string.toString(s) ~ "\"];\n";
		if(left) {
			str ~= std.string.toString(toHash) ~ " -> " ~ std.string.toString(left.toHash) ~ ";\n";
			str ~= left.toString();
		} else {
			str ~= std.string.toString(toHash) ~ "00 [label=\"\", shape=\"box\"];\n";
			str ~= std.string.toString(toHash) ~ " -> " ~ std.string.toString(toHash) ~ "00;\n";
		}
		if(right) {
			str ~= std.string.toString(toHash) ~ " -> " ~ std.string.toString(right.toHash) ~ ";\n";
			str ~= right.toString();
		} else {
			str ~= std.string.toString(toHash) ~ "11 [label=\"\", shape=\"box\"];\n";
			str ~= std.string.toString(toHash) ~ " -> " ~ std.string.toString(toHash) ~ "11;\n";
		}
		
		return str;
	}
}
/*
void main() {
	auto heap1 = new LeftHeap!(string)(true);
	heap1.insert(4, "");
	heap1.insert(8, "");
	heap1.insert(8, "");
	heap1.insert(6, "");
	heap1.insert(6, "");
	
	auto heap2 = new LeftHeap!(string)(true);
	heap2.insert(3, "");
	heap2.insert(5, "");
	heap2.insert(6, "");
	heap2.insert(9, "");
	
	heap1.insert(heap2);
	
	auto values = heap1.toValueArray;
	writef("[");
	foreach(v; values) {
		writef(" %d ", v);
	}
	writefln("]");
}*/
