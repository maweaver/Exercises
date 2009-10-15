module util.dlx;

import std.stdio;
import std.string;

/++
 + The type of a DLX node
 +/
enum DlxNodeType {
	Root,     /// h; only uses left/right
	Column,   /// Column header; uses left, right, up, down, size, and name
	Cell      /// A single cell; uses left, right, up, down and column
}

/++
 + A doubly-linked node.  Intentionally terse, to match Knuth's nomenclature and
 + because they're used a lot.
 +/
class DlxNode {
	/++
	 + Constructor
	 +/
	this(DlxNodeType type,
	     DlxNode l = null, DlxNode r = null, DlxNode u = null, DlxNode d = null,
			 DlxNode c = null, int s = 0, string n = "") {
		this.type = type;
		this.l = l; this.r = r; this.u = u; this.d = d;
		this.c = c; this.s = s; this.n = n;
	}
	
	DlxNodeType type;   /// Type of node
	DlxNode l;          /// Node to the left
	DlxNode r;          /// Node to the right
	DlxNode u;          /// Node up
	DlxNode d;          /// Node down
	DlxNode c;          /// Column header
	int s;              /// Size of the column
	string n;           /// Identifier
}

/++
 + A singly-linked list, used to return the results.  The results of searching
 + is a set of rows whose 1's make up a cover of all columns.
 +/
class DlxResult {
	/++
	 + Constructor
	 +/
	this(DlxNode r, DlxResult n) {
		this.r = r;
		this.n = n;
	}
	
	DlxNode r;     /// The row of this result
	DlxResult n;   /// The next row in the set.
	
	/++
	 + String representation of the result.  This looks something like:
	 +
	 +   { A D } { B G } { E F C }
	 +
	 + This means there are three rows in the result, one of which had 1's in
	 + columns A and D, one of which had 1's in columns B and G, and one of
	 + which had ones in columns E, F, and C.  It is clear that these rows form
	 + a cover set of { A B C D E F G }
	 +/
	string toString() {
		char[] res;
		
		res ~= "{ ";
		
		auto cell = r;
		do {
			res ~= cell.c.n ~ " ";
			cell = cell.r;
		} while(cell != r);
		
		res ~= "} ";
		if(n) {
			res ~= n.toString;
		}
		
		return cast(string)(res);
	}
}

/++
 + Class implementing the DLX algorithm.
 +/
class Dlx {
	protected:
	
	DlxNode h;
	
	/++
	 + Creates a new column to the right side of the matrix.
	 +/
	void addColumn(string n) {
		auto c = new DlxNode(DlxNodeType.Column,
		                     h.l, h, null, null,
										     null, 0, n);
		h.l.r = c;
		h.l = c;
		c.u = c;
		c.d = c;
		c.c = c;
	}

	/++
	 + Determines the offset of a given column node.  If it is the first column
	 + to the right of h, the return value will be 1, and so forth.
	 +/
	int colOffset(DlxNode c) {
		int offset = 0;
		while(c != h) {
			offset++;
			c = c.l;
		}
		return offset;
	}
	
	/++
	 + Returns the column at the given offset from h.  The first column to the
	 + right of h has an offset of 1, the second 2, etc.  (An offset of 0 will
	 + return h).
	 +/
	DlxNode colAt(int offset) {
		auto c = h;
		for(int k = 0; k < offset; k++) {
			c = c.r;
		}
		return c;
	}
	
	/++
	 + Returns the column with the lowest S, i.e., the one with the least number
	 + of 1's in it.
	 +/
	DlxNode minCol() {
		DlxNode min = null;
		for(auto c = h.r; c != h; c = c.r) {
			if(!min || c.s < min.s) {
				min = c;
			}
		}
		return min;
	}

	/++
	 + Covers the given column.  Removes the given column, and all rows with a 1 in that column.  Returns the
	 + column, so that it can be uncovered later.
	 +/
	DlxNode cover(DlxNode c) {
		c.r.l = c.l;
		c.l.r = c.r;
		
		for(auto row = c.d; row != c; row = row.d) {
			for(auto cell = row.r; cell != row; cell = cell.r) {
				cell.u.d = cell.d;
				cell.d.u = cell.u;
				cell.c.s--;
			}
		}
		
		return c;
	}

	/++
	 + Uncovers the given column, restoring the column and all the rows attached to it.
	 +/
	void uncover(DlxNode c) {
		c.r.l = c;
		c.l.r = c;
		
		for(auto row = c.d; row != c; row = row.d) {
			row.r.l = row;
			row.l.r = row;
			
			for(auto cell = row.r; cell != row; cell = cell.r) {
				cell.u.d = cell;
				cell.d.u = cell;
				cell.c.s++;
			}
		}
	}
	
	/++
	 + Actual implementation of the search algorithm.  Calls itself recursively.
	 +/
	DlxResult[] search(DlxResult res, bool enumerate) {
		if(h.r == h) {
			return [ res ];
		}
		
		DlxResult[] all;
		auto c = cover(minCol());
		for(auto r = c.d; r != c; r = r.d) {
			
			for(auto j = r.r; j != r; j = j.r) {
				cover(j.c);
			}

			foreach(result; search(new DlxResult(r, res), enumerate)) {
				all ~= result;
			}
			
			for(auto j = r.r; j != r; j = j.r) {
				uncover(j.c);
			}
			
			if(all.length > 0 && !enumerate) {
				// Break out early if not enumerating
				break;
			}
		}
		
		uncover(c);
		
		return all;
	}

  /++ 	
	 + Uses the following algorithm to find a row using the given spec
	 +
	 +   - Start at h
	 +   - Move right for each entry in the spec array
	 +     - When you encounter a 1, for the first time, build an array of all 
	 +       cells in that column
	 +     - For subsequent 1's, set the cell array to all cells whose l is in the 
	 +       original cell array
	 +   - For each row in this set, find the cell whose column to the right is
	 +     the first one that had a 1 originally.
	 +/
	DlxNode findRow(int[] spec) {
		DlxNode[] possibleCells;
		DlxNode firstCol = null;
		auto col = h;
		foreach(r; spec) {
			col = col.r;
			
			if(r != 0) {
				if(!firstCol) {
					for(auto cell = col.d; cell != col; cell = cell.d) {
						possibleCells ~= cell;
					}
					firstCol = col;
				} else {
					DlxNode[] newPossibleCells;
					for(auto cell = col.d; cell != col; cell = cell.d) {
						foreach(p; possibleCells) {
							if(cell.l == p) {
								newPossibleCells ~= cell;
							}
						}
					}
					possibleCells = newPossibleCells;
				}
			}
		}
		
		foreach(cell; possibleCells) {
			if(cell.r.c == firstCol) {
				return cell;
			}
		}
		
		return null;
	}

	/++
	 + The non-recursive portion of searching.  Nicer interfaces to this method
	 + are provided via search() and enumerate().
	 +/
	DlxResult[] search(int[][] constraints, bool enumerate) {
		DlxNode[] initiallycovered;
		DlxResult res = null;
		
		foreach(constraint; constraints) {
			auto row = findRow(constraint);
			if(row) {
				res = new DlxResult(row, res);

				auto cell = row;
				do {
					initiallycovered ~= cell.c;
					cell = cell.r;
				} while(cell != row);		
			} else {
				writefln("No matching row found for constraint!");
			}
		}
		
		foreach(covered; initiallycovered) {
			cover(covered);
		}
		
		auto ans = search(res, enumerate);
		
		foreach(covered; initiallycovered) {
			uncover(covered);
		}
		
		return ans;
	}
	
	public:
	
	/++
	 + Constructor.
	 +/
	this(string[] columns) {
		h = new DlxNode(DlxNodeType.Root);
		h.l = h;
		h.r = h;
		h.c = h;
		
		foreach(c; columns) {
			addColumn(c);
		}
	}
	
	/++
	 + Adds a new row.  DLX nodes are added to each column in which the 
	 + corresponding value in the cols array is not 0.  Not that the only factor
	 + taken into consideration is whether the value is 0 or otherwise; actual
	 + values are ignored.
	 +
	 + Assumes that cols.length is the same as the actual number of columns, 
	 + otherwise the results are unpredictable.
	 +/
	void addRow(int[] cols) {
		auto c = h.r;
		DlxNode l = null;
		DlxNode first = null;
		
		foreach(col; cols) {
			if(col != 0) {
				auto cell = new DlxNode(DlxNodeType.Cell,
				                        l, null, c.u, c, c);
				if(l) {
					l.r = cell;
				} else {
					cell.l = cell;
				}
				if(!first) {
					first = cell;
				}
				cell.r = first;
				c.u.d = cell;
				c.u = cell;
				l = cell;
				c.s++;
			}
			c = c.r;
		}
		
		if(first) {
			first.l = l;
		}
	}
	
	/++
	 + Use opCat to concatenate rows
	 +/
	Dlx opCat(int[] cols) {
		addRow(cols);
		return this;
	}
	
	/++
	 + Searches for a cover set of this matrix, and returns the first one found.
	 +/
	DlxResult search(int[][] constraints = [ ]) {
		auto res = search(constraints, false);
		if(res.length > 0) {
			return res[0];
		} else {
			return null;
		}
	}
	
	/++
	 + Discovers all cover sets of this matrix, and returns them in an array.
	 +/
	DlxResult[] enumerate(int[][] constraints = [ ]) {
		return search(constraints, true);
	}
	
	/++
	 + Returns a pretty-print of the dancing-links data structure, which can be
	 + transformed into a graphic representation using graphviz's neato tool.
	 +/
	string toString() {
		// This is a little messy.  Graphviz's layout algorithms don't work well for
		// this graph, so we absolute position everything manually.  The hard part
		// about this is the ordering of the rows.  To explain, consider a simple
		// example:
		//
		//   A B C
		//   0 1 0
		//   1 0 0
		//   1 1 1
		//
		// Recall that the way to get to a cell from the head node is to iterate to
		// the next header, then move down from the column header into the cell.
		// The problem is, from this perspective (A, 1), (B, 0), and (C, 2) all
		// appear exactly the same, but should actually end up on three different
		// levels in the graph.
		//
		// To solve this problem, an intermediate GraphNode data structure is used.
		// A first pass is done by moving across each column, and then down through
		// the entries in the column.  A graph node is created for each entry in
		// the corresponding row, and that row is marked as processed.  Rows are
		// added in the order they are encountered.
		// 
		// For example, in the above matrix we would start by moving over to column
		// A, then down to row 2 (though we do not know that it was the second
		// row originally), then row 3, then finally move over to column B and
		// process row 1.
		//
		// Next, a second pass is done to find any rows that are displayed out of
		// order, and swap them.  This pass repeats until all rows are in order.
		// Continuing with our example, first column A is checked.  The first row
		// is displayed first, and the second row is displayed second, so all is 
		// well.
		//
		// The check continues to column B.  The first row of column B is displayed
		// third, and the second row is displayed second, so rows 2 and 3 are 
		// swapped, and the check restarts.
		//
		// This time, the first row of column A is still displayed first and the
		// second row is displayed third, so they are still in order.  The check
		// proceeds to column B.  The first row of column B is displayed second and
		// the third row is displayed third, so column B passes.  Column C only has
		// one row, so it passes.
		//
		// Note that the final displayed version is semantically equivalent to the
		// original, but the rows are not displayed in the same order they were
		// specified.  In this case, the final displayed value is:
		//
		//   A B C
		//   1 0 0
		//   0 1 0
		//   1 1 1
		//
		// This is not a deficiency in the algorithm; there is no longer enough
		// information to determine whether row 1 or row 2 should be displayed
		// first.
		//
		// This display algorithm has a much worse running time than the algorithm
		// itself, and should only be used for diagnostic purposes.  Specifically,
		// if the input is an mxn matrix, the first part of the algorithm
		// (building the graph nodes) is O(mn).  The second part (reordering the
		// rows) can be seen as a modified bubble sort, which in the worst case is
		// O((mn)^2).
		
		/++
		 + Data structure used to store intermediate information on how to construct
		 + the display graph
		 +/
		struct GraphNode {
			int x;
			int y;
			string label;
			int[] connections;
		}
		
		// A mapping between the actual nodes and their graphic representations
		GraphNode[DlxNode] nodes;
		
		/++
		 + Switch the two display rows at the given y values
		 +/
		void switchRows(int y1, int y2) {
			foreach(ref n; nodes) {
				if(n.y == y1) {
					n.y = y2;
				} else if(n.y == y2) {
					n.y = y1;
				}
			}
		}
		
		// Build the initial graph objects
		
		nodes[h] = GraphNode(0, 0, "h");

		int currow = 1;
		for(auto col = h.r, curcol = 1; col != h; col = col.r, curcol++) {
			
			nodes[col] = GraphNode(curcol, 0, format("%s [%d]", col.n, col.s), [
				col.l.toHash,
				col.r == h ? 0 : col.r.toHash,
				col.d == col ? 0 : col.d.toHash]);
			
			for(auto row = col.d; row != col; row = row.d) {
				if(!(row in nodes)) {
					auto cell = row;
					do {
						nodes[cell] = GraphNode(colOffset(cell.c), -currow, "1", [
							cell.u.toHash,
							cell.d == cell.c ? 0 : cell.d.toHash,
							cell.r == row ? 0 : cell.r.toHash,
							cell == row ? 0 : cell.l.toHash ]);
						cell = cell.r;
					} while(cell != row)
				
					currow++;
				}
			}
		}
		
		// Rearrange the rows
		
		auto col = h.r;
		while(col != h) {
			for(auto row = col.d; row != col; row = row.d) {
				auto upy = nodes[row.u].y;
				auto y = nodes[row].y;
				
				if(y > upy) {
					switchRows(y, upy);
					col = h;
					break;
				}
			}
			col = col.r;
		}
		
		// Build the final graph string
		
		string res;
		
		res ~= "graph G {\n";
		foreach(dlx, n; nodes) {
			res ~= format("%x [label=\"%s\" shape=box pos=\"%d,%d\" pin=true];\n", dlx.toHash, n.label, n.x, n.y);
			foreach(c; n.connections) {
				if(c != 0) {
					res ~= format("%x -- %x;\n", dlx.toHash, c);
				}
			}
		}
		res ~= "}";
		return res;
	}
}
