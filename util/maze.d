module util.maze;

import std.stdio;

import util.point;
import util.queue;
import util.size;
import util.stack;
import util.visualizer;

/++
 + A maze is a generalized 2-d grid used for a variety of search problems.  Each
 + point on the grid is represented by an integer value.
 +/
class Maze {
	private:
	
	Size _size;
	int[][] tiles;
	
	Point[] relativeMoves;

	Point _start;
	Point _goal;
	
	int _numFrames;
	string _title;
	int _frameSpeed;
	
	protected:
	
	int vizScale = 64;
	int vizBorder = 10;

	int UNVISITED = 0;
	int VISITED = -1;
	int OBSTACLE = -2;

	Stack!(Point) moves;
	
	public:
	
	/++
	 + Constructor
	 +/
	this(Size size, Point start, Point goal, Point[] relativeMoves, string title = "Maze", int frameSpeed = 1000) {
		this.relativeMoves = relativeMoves;
		_size = size;
		_start = start;
		_goal = goal;
		tiles = new int[][](size.iwidth, size.iheight);
		_numFrames = 1;
		_title = title;
		_frameSpeed = frameSpeed;
		moves = new Stack!(Point)(size.iwidth * size.iheight);
	}
	
	/++
	 + Size
	 +/
	Size size() {
	  return _size;
	}

	/++
	 + Start point
	 +/
	Point start() {
		return _start;
	}
	
	/++
	 + Goal point
	 +/
	Point goal() {
		return _goal;
	}
	
	/++
	 + Number of frames in the visualization
	 +/
	int numFrames() {
		return _numFrames;
	}
	
	/++
	 + Title of the visualization
	 +/
	string title() {
		return _title;
	}
	
	/++
	 + Speed of the visualization
	 +/
	int frameSpeed() {
		return _frameSpeed;
	}
	
	/++
	 + Returns the value of the tile at the given location
	 +/
	int tileAt(Point p) {
		return tiles[p.ix][p.iy];
	}
	
	/++
	 + Modifies the value of the tile at the given location
	 +/
	void setTile(Point p, int val) {
		tiles[p.ix][p.iy] = val;
	}
	
	/++
	 + Calculates all possible moves based on the relative moves array
	 +/
	Point[] movesFrom(Point p) {
		Point[] res;
		foreach(move; relativeMoves) {
			auto p2 = p + move;
			if(visitable(p2)) {
				res ~= p2;
			}
		}
		return res;
	}
	
	/++
	 + Returns true if p is within the boundaries of the maze, or false if not
	 +/
	bool inBounds(Point p) {
		return p.x >= 0 && p.x < size.width && p.y >= 0 && p.y < size.height;
	}
	
	/++
	 + Whether the maze is solved.  Usually just p == goal
	 +/
	bool solved(Point p) {
		return (p == goal) != 0;
	}
	
	/++
	 + Whether it is ok to visit the given point
	 +/
	abstract bool visitable(Point p);
	
	/++
	 + The search operator determines the points to move to from p, or [] if there is no such move
	 +/
	abstract Point[] searchOperator(Point p);
	
	/++
	 + Visits the given point
	 +/
	abstract void visit(Point p);
	
	/++
	 + Unvisits the given point
	 +/
	abstract void unvisit(Point p);
	
	/++
	 + Do any drawing before the frame is drawing
	 +/
	abstract void preDrawFrame(Canvas c, int frameNum);
	
	/++
	 + Do any drawing after the frame is drawing
	 +/
	abstract void postDrawFrame(Canvas c, int frameNum);
	
	/++
	 + Draw the given tile
	 +/
	abstract void drawTile(Canvas c, Point p, Point ul, Point lr, int frameNum);
	
	Point depthSearchRecursive(Point p) {
		moves.push(p);
		
		visit(p);
		if(solved(p)) {
			return p;
		}
		
		foreach(m; searchOperator(p)) {
			if(visitable(m)) {
				auto ret = depthSearchRecursive(m);
				if(ret.x == -1 && ret.y == -1) {
					return ret;
				}
			}
		}
		
		unvisit(p);
		moves.pop();
		
		return new Point(-1, -1);
	}
	
	/++
	 + Performs a depth-first search using an explicit stack
	 +/
	Point depthSearch(Point start) {
		moves.push(start);
		visit(start);
		
		while(!moves.isEmpty) {
			auto p = moves.peek();
			visit(p);
			
			if(solved(p)) {
				return p;
			} else {
				auto next = searchOperator(p);
				if(next.length > 0) {
					moves.push(next[0]);
				} else {
					moves.pop();
				}
			}
		}
		
		return new Point(-1, -1);
	}
	
	/++
	 + Performs a breadth-first search using an explicit stack
	 +/
	Point breadthSearch(Point start) {
		auto predecessors = new Point[][](size.iwidth, size.iheight);
		auto movesQueue = new Queue!(Point)();
		
		movesQueue.push(start);
		
		while(!movesQueue.isEmpty) {
			auto thisMove = movesQueue.pop();
			// Rebuild the moves array for each time
/*			moves = new Stack!(Point)();
			auto curMove = thisMove;
			do {
				moves.push(curMove);
				curMove = predecessors[curMove.x][curMove.y];
			} while(curMove.x != 0 && curMove.y != 0);*/
			visit(thisMove);
			if(solved(thisMove)) {
				return thisMove;
			}
			
			foreach(nextMove; searchOperator(thisMove)) {
				if(predecessors[nextMove.ix][nextMove.iy].x == 0) {
					predecessors[nextMove.ix][nextMove.iy] = thisMove;
				
					movesQueue.push(nextMove);
				}
			}
		}
		
		return new Point(-1, -1);
	}
	
	Point breadthSearchRecursive(Point start) {
		auto startPath = new Stack!(Point)();
		startPath.push(start);
		return breadthSearchRecursiveStep([ BreadthSearchInfo(start, startPath) ]);
	}
	
	static struct BreadthSearchInfo {
		Point p;
		Stack!(Point) path;
	}
	
	Point breadthSearchRecursiveStep(BreadthSearchInfo[] infos) {
		BreadthSearchInfo[] nextStep;
		
		foreach(info; infos) {
			moves = info.path;
			auto p = info.p;
			visit(p);
			if(solved(p)) {
				return p;
			} else {
				auto next = searchOperator(p);
				foreach(n; next) {
					auto nextMoves = new Stack!(Point)(moves);
					nextMoves.push(n);
					nextStep ~= BreadthSearchInfo(n, nextMoves);
				}
			}
		}
		
		if(nextStep.length == 0) {
			return new Point(-1, -1);
		} else {
			return breadthSearchRecursiveStep(nextStep);
		}
	}
	
	/++
	 + Creates a visualization of the board
	 +/
	void visualize() {
		createVisualization(title, 
			&drawFunction, 
			frameSpeed, [ new MazeFrameData(this) ], numFrames, 
			new Size(size.width * vizScale + 2 * vizBorder, 
				       size.height * vizScale + 2 * vizBorder));
	}
	
	static void drawFunction(Canvas c, int frameNum, FrameData frameData) {
		auto mazeFrameData = cast(MazeFrameData) frameData;
		if(mazeFrameData) {
			auto size = mazeFrameData.maze.size;
			auto vizScale = mazeFrameData.maze.vizScale;
			auto vizBorder = mazeFrameData.maze.vizBorder;
			
			c.logicalWidth = size.iwidth * vizScale + 2 * vizBorder;
			c.logicalHeight = size.iheight * vizScale + 2 * vizBorder;
			c.useWindowCoordinates();
			
			mazeFrameData.maze.preDrawFrame(c, frameNum);
			
			for(int x = 0; x < size.iwidth; x++) {
				for(int y = 0; y < size.iheight; y++) {
					mazeFrameData.maze.drawTile(c, new Point(x, y),
						new Point(x * vizScale + vizBorder, y * vizScale + vizBorder),
						new Point((x + 1) * vizScale + vizBorder, (y + 1) * vizScale + vizBorder),
						frameNum);
				}
			}
			
			mazeFrameData.maze.postDrawFrame(c, frameNum);
		}
	}
}

/++
 + Frame data used to visualize a maze
 +/
class MazeFrameData: FrameData {
	private:
	
	Maze _maze;
	
	public:
	
	/++
	 + Constructor
	 +/
	this(Maze maze) {
		_maze = maze;
	}
	
	/++
	 + The maze containing the data
	 +/
	Maze maze() {
		return _maze;
	}
	
}
