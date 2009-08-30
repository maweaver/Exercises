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
	char[] toString() {
		string res = "{ ";
		
		auto cell = r;
		do {
			res ~= cell.c.n ~ " ";
			cell = cell.r;
		} while(cell != r);
		
		res ~= "} ";
		if(n) {
			res ~= n.toString;
		}
		
		return res;
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

/++
 + A sudoku solver which uses the Dlx algorithm.  The idea is to transform a
 + sudoku puzzle into a matrix so that each unique cover of the matrix 
 + represents a solution to the puzzle.
 +
 + We create the matrix by creating a column for each constraints.  For example,
 + each number 1-9 has to occur exactly once in row 1, so we add a column R11,
 + R12, ... R19 to represent this constraints.  Similarly for columns 1-9 and
 + groups 1-9.
 +
 + We create an entry for each row-column-number combination.  The group value
 + is dependent on the combination of row and column. The final size of this 
 + matrix is 243 x 729.
 +
 + It is easy to see that each cover set to this matrix is a solution to an
 + unconstrained sudoku problem.
 +
 + To solve a specific problem, we cover each column with a '1' in the row 
 + representing the given number.  For example, if we are given that row 1 
 + column 2 has a value 3, we know that we have accounted for R13, C23, and G13.
 + Those columns, and any rows that have a 1 in that column, can be removed.
 +
 + This reduces the size of the matrix and gives a partial solution 
 + corresponding to those rows.  The result is then a cover set of the remaining
 + matrix.
 +/
class SudokuSolver {
	protected:
	
	Dlx dlx;
	
	/++
	 + Returns the offset of the row-column combo r-c
	 +/
	int offsetRc(int r, int c) {
		return 9 * 9 * 0 + r * 9 + c;
	}
	
	/++
	 + Returns the offset of the column for row r number n
	 +/
	int offsetR(int r, int n) {
		return 9 * 9 * 1 + r * 9 + n;
	}
	
	/++
	 + Returns the offset of the column for col c number n
	 +/	
	int offsetC(int c, int n) {
		return 9 * 9 * 2 + c * 9 + n;
	}
	
	/++
	 + Returns the offset of the column for group g number n
	 +/
	int offsetG(int g, int n) {
		return 9 * 9 * 3 + g * 9 + n;
	}
	
	/++
	 + Returns the group number of the given row-column combo
	 +/
	int groupOf(int r, int c) {
		return (r / 3) * 3 + (c / 3);
	}
	
	public:
	
	/++
	 + Constructor.  Generates the DLX matrix (an expensive operation) once, so
	 + that it can be reused to solve many puzzles quickly.
	 +/
	this() {
		// Build the columns.  These should relate to the mathematical relationship
		string[9 * 9 * 4] columns;
		for(int row = 0; row < 9; row++) {
			for(int n = 0; n < 9; n++) {
				columns[offsetR(row, n)] = format("R%d%d", row + 1, n + 1);
			}
			
			for(int col = 0; col < 9; col++) {
				columns[offsetRc(row, col)]  = format("RC%d%d", row + 1, col + 1);
				for(int n = 0; n < 9; n++) {
					columns[offsetC(col, n)] = format("C%d%d", col + 1, n + 1);
					columns[offsetG(groupOf(row, col), n)] = format("G%d%d", groupOf(row, col) + 1, n + 1);
				}
			}
		}
	
		dlx = new Dlx(columns);
	
		// Build a row for each row-col-num combo
	
		for(int row = 0; row < 9; row++) {
			for(int col = 0; col < 9; col++) {
				for(int n = 0; n < 9; n++) {
					int[(9 * 9) * 4] values;
					values[offsetRc(row, col)] = 1;
					values[offsetR(row, n)] = 1;
					values[offsetC(col, n)] = 1;
					values[offsetG(groupOf(row, col), n)] = 1;
					dlx.addRow(values);
				}
			}
		}
	}
	
	/++
	 + Solves the given puzzle.  Puzzles are given as an 81-character string of
	 + characters.  Characters '1' - '9' in a given spot means that that location
	 + is locked to the given number.  Any other number or character means that
	 + the given location is free.
	 +/
	string solve(string puzzle) {
		assert(puzzle.length == 81);
		
		string res;
		res.length = 81;
		
		// Build constraints for the input puzzle
		int[][] constraints;
		foreach(idx, ch; puzzle) {
			int row = idx / 9;
			int col = idx % 9;
			int val = ch - '0';
			if(val < 1 || val > 9) {
				val = 0;
			}
			
			if(val != 0) {
				auto constraint = new int[9 * 9 * 4];
				
				constraint[offsetRc(row, col)] = 1;
				constraint[offsetR(row, val - 1)] = 1;
				constraint[offsetC(col, val - 1)] = 1;
				constraint[offsetG(groupOf(row, col), val - 1)] = 1;
				
				constraints ~= constraint;
			}
		}
		
		auto ans = dlx.search(constraints);
		if(ans) {
			while(ans) {
				int row;
				int col;
				int val;
				
				auto cell = ans.r;
				do {
					if(cell.c.n.length == 4) {
						row = cell.c.n[2] - '0';
						col = cell.c.n[3] - '0';
					} else if(cell.c.n[0] == 'C') {
						val = cell.c.n[2];
					}
					
					cell = cell.r;
				} while(cell != ans.r)
				
				res[(row - 1) * 9 + (col - 1)] = val;
				ans = ans.n;
			}
		} else {
			writefln("No answer found");
		}
	
		return res;
	}
	
	/++
	 + Takes a packed string representing a puzzle and prints it formatted nicely to standard out
	 +/
	void prettyPrint(string puzzle) {
		for(auto row = 0; row < 9; row++) {
			for(auto col= 0; col < 9; col++) {
				auto val = puzzle[row * 9 + col];
				if(val != '0') {
					writef(" %s ", val);
				} else {
					writef(" _ ");
				}
				if(col < 8 && (col + 1) % 3 == 0) {
					writef(" | ");
				}
			}
			writefln();
			if(row < 8 && (row + 1) % 3 == 0) {
				for(int i = 0; i < (9 + 2) * 3; i++) {
					if(i == 10 || i == 22) {
						writef("+");
					} else {
						writef("-");
					}
				}
				writefln();
			}
		}
	}
}

void main() {
	/*
	// Modified (to add a second cover set) version of Knuth's sample
	auto dlx = 
	  new Dlx(["A", "B", "C", "D", "E", "F", "G" ]) ~
		        [ 0,   0,   1,   0,   1,   1,   0  ] ~
		        [ 1,   0,   0,   1,   0,   0,   1  ] ~
		        [ 0,   1,   1,   0,   0,   1,   0  ] ~
		        [ 1,   0,   0,   1,   0,   0,   0  ] ~
		        [ 0,   1,   0,   0,   0,   0,   1  ] ~
		        [ 0,   0,   0,   1,   1,   0,   1  ] ~
						[ 1,   1,   1,   0,   0,   1,   0  ];
	
	// Find all solutions which include the row with a 1 in columns D and A
	foreach(ans; dlx.enumerate([ [ 1, 0, 0, 1, 0, 0, 0 ] ])) {
		writefln("%s", ans);
	}
	*/
	
	auto solver = new SudokuSolver();
	for(auto puzzle = readln(); puzzle; puzzle = readln()) {
		writefln("%s", solver.solve(puzzle[0..81]));
	}
}
