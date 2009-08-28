/////////////////////////////////////////////////////////////////////
//
//  Sudoku Solver using Knuth's Dancing Links algorithm (DLX)
//
/////////////////////////////////////////////////////////////////////

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
	 + Uncovers the given column, restoring the column and all the rows attached to it.
	 +/
	DlxNode uncover(DlxNode c) {
		
	}
	
	/++
	 + Covers the given column.  Removes the given column, and all rows with a 1 in that column.  Returns the
	 + column, so that it can be uncovered later.
	 +/
	DlxNode cover(DlxNode c) {
		c.r.l = c.l;
		c.l.r = c.r;
		
		for(auto row = c.d; row != c; row = row.d) {
			auto cell = row;
			do {
				cell.u.d = cell.d;
				cell.d.u = cell.u;
				cell = cell.r;
			} while(cell != row);

			row.r.l = row.l;
			row.l.r = row.r;
		}
	}

	/++
	 + Returns a pretty-print of the dancing-links data structure, which can be
	 + transformed into a graphic representation using graphviz's neato tool.
	 +/
	char[] toString() {
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
			
			nodes[col] = GraphNode(curcol, 0, col.n, [
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
		
		for(auto col = h.r, curcol = 1; col != h; col = col.r, curcol++) {
			for(auto row = col.d; row != col; row = row.d) {
				
				auto upRowY = nodes[row.u].y;
				auto rowY = nodes[row].y;
				
				if(rowY > upRowY) {
					switchRows(rowY, upRowY);
					col = h.r;
					break;
				}
			}
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

void main() {
	auto dlx = 
	  new Dlx(["A", "B", "C", "D", "E", "F", "G" ]) ~
		        [ 0,   0,   1,   0,   1,   1,   0  ] ~
		        [ 1,   0,   0,   1,   0,   0,   1  ] ~
		        [ 0,   1,   1,   0,   0,   1,   0  ] ~
		        [ 1,   0,   0,   1,   0,   0,   0  ] ~
		        [ 0,   1,   0,   0,   0,   0,   1  ] ~
		        [ 0,   0,   0,   1,   1,   0,   1  ];

	dlx.cover(0);
	
	writefln("%s", dlx.toString());
}
