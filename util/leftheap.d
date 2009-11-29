module util.leftheap;

import std.conv;
import std.math;
import std.stdio;

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
	protected:
	
	bool _minHeap;
	LeftHeapNode!(T) root;
	LeftHeapNode!(T)[T] nodeLookup;
	
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
		nodeLookup[data] = node;
		if(!root) {
			root = node;
		} else {
			root = merge(root, node);
		}
	}
	
	/++
	 + Insert another leftheap
	 +/
	void insert(LeftHeap!(T) heap) {
		foreach(data, node; heap.nodeLookup) {
			nodeLookup[data] = node;
		}
		root = merge(root, heap.root);
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
		nodeLookup.remove(data);
		if(root.left) {
			root = merge(root.left, root.right);
		} else {
			root = root.right;
			if(root) {
				root.parent = null;
			}
		}
		nodeLookup.remove(data);
		return data;
	}
	
	/++
	 + Returns the next value, or null if there is none
	 +/
	int pollValue() {
		if(root) {
			int value = root.value;
			nodeLookup.remove(root.data);
			if(root.left) {
				root = merge(root.left, root.right);
			} else {
				root = root.right;
				if(root) {
					root.parent = null;
				}
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
	 + Removes node with the given data.  Stops after removing a single node.  Takes O(n) time, since nodes are
	 + not ordered by their data.
	 +/
	void remove(T data) {
		/*
		bool search(LeftHeapNode!(T) node, LeftHeapNode!(T) parent, bool left) {
			if(!node) {
				return false;
			} else if(node.data == data) {
				auto merged = merge(node.left, node.right);
				
				if(parent) {
					if(left) {
						parent.left = merged;
					} else {
						parent.right = merged;
					}
					updateRank(parent);
				} else {
					root = merged;
				}
				
				return true;
			} else {
				if(node.left) {
					if(search(node.left, node, true)) {
						return true;
					}
				}
				if(node.right) {
					if(search(node.right, node, false)) {
						return true;
					}
				}
				
				return false;
			}
		}
		
		search(root, null, false);*/
		
		if(data in nodeLookup) {
			auto node = nodeLookup[data];
			auto merged = merge(node.left, node.right);
			if(node.parent) {
				if(node.parent.left == node) {
					node.parent.left = merged;
				} else if(node.parent.right == node) {
					node.parent.right = merged;
				}
				childrenModified(node.parent);
			} else {
				root = merged;
			}
		}
	}

	/++
	 + Returns a .dot representation of the graph
	 +/
	string toString() {
		return "digraph G {\n" ~
		(root ? root.toString() : "\n") ~
			"}";
	}
	
	protected:
	
	/++
	 +  Updates the rank of the given node by calculating the minimum rank of its children and adding 1.  Also
	 + ensures the left child has the higher rank.
	 +/
	void childrenModified(LeftHeapNode!(T) node) {
		int sleft = node.left ? node.left.s : 0;
		int sright = node.right ? node.right.s : 0;
		
		node.s = cast(int) fmin(sleft, sright) + 1;
		
		if(sleft < sright) {
			auto tmp = node.left;
			node.left = node.right;
			node.right = tmp;
		}	
	}
	
	/++
	 +  Merges two nodes to create a new node containing both nodes and their children.
	 +/
	LeftHeapNode!(T) merge(LeftHeapNode!(T) node1, LeftHeapNode!(T) node2) {
		if(!node2) {
			return node1;
		}
		if(!node1) {
			return node2;
		}
		
		// writefln("Merging node %d with node %d", a.value, b.value);
		LeftHeapNode!(T) upper;
		LeftHeapNode!(T) lower;
		
		if(node1.value < node2.value) {
			upper = node1;
			lower = node2;
		} else {
			upper = node2;
			lower = node1;
		}
		
		if(!minHeap) {
			auto tmp = upper;
			upper = lower;
			lower = tmp;
		}
		
		if(upper.right) {
			upper.right = merge(upper.right, lower);
		} else {
			upper.right = lower;
		}
		upper.right.parent = upper;
		
		childrenModified(upper);
		
		return upper;
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
	 + Parent
	 +/
	LeftHeapNode!(T) parent;
	
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
	
	string toString() {
		auto str = to!(string)(toHash) ~ " [label=\"" ~ to!(string)(value) ~ ":" ~ to!(string)(s) ~ "\"];\n";
		if(left) {
			str ~= to!(string)(toHash) ~ " -> " ~ to!(string)(left.toHash) ~ ";\n";
			str ~= left.toString();
		} else {
			str ~= to!(string)(toHash) ~ "00 [label=\"\", shape=\"box\"];\n";
			str ~= to!(string)(toHash) ~ " -> " ~ to!(string)(toHash) ~ "00;\n";
		}
		if(right) {
			str ~= to!(string)(toHash) ~ " -> " ~ to!(string)(right.toHash) ~ ";\n";
			str ~= right.toString();
		} else {
			str ~= to!(string)(toHash) ~ "11 [label=\"\", shape=\"box\"];\n";
			str ~= to!(string)(toHash) ~ " -> " ~ to!(string)(toHash) ~ "11;\n";
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
	heap2.insert(3, "a");
	heap2.insert(5, "b");
	heap2.insert(6, "c");
	heap2.insert(9, "d");
	
	heap1.insert(heap2);
	
	heap1.remove("b");
	
	auto values = heap1.toValueArray;
	writef("[");
	foreach(v; values) {
		writef(" %d ", v);
	}
	writefln("]");
}*/
