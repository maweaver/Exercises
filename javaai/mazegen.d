import std.random;
import std.stdio;
import std.c.stdio;

import util.leftheap;
import util.maze;
import util.size;
import util.stack;
import util.visualizer;

/++
 + This class generates a maze using a depth-first search algorithm.  The size of the generated maze will be
 + 2n + 1.  Obstacles are given a value of -2.  Border tiles are always obstacles.  Tiles whose x-and y- 
 + coordinates are odd are always open.  Walls whose x- and y- coordinates are even always solid.  Walls whose
 + x-coordinate is odd and y-coordinate is even, or vice-versa, form the "walls" of the maze, and may be
 + either solid or open.  All open spaces are connected.
 +/
class MazeGen: Maze {
	
	private:
	
	Stack!(Point) points;
	int curTurn;
		
	public:
	
	this(Size inSize) {
		super(new Size(inSize.iwidth * 2 + 1, inSize.iheight * 2 + 1), Point(cast(int) ((rand() % inSize.width) * 2 + 1), cast(int) ((rand() % inSize.height) * 2 + 1)), Point(0, 0),
			[ Point(-2, 0), Point(0, -2), Point(2, 0), Point(0, 2) ],
			"Generated Maze", 1000);
		
		// Start out by filling the borders and all walls
		for(int x = 0; x < size.iwidth; x++) {
			for(int y = 0; y < size.iheight; y++) {
				if(x == 0 || y == 0 || x == (size.iwidth - 1) || y == (size.iheight - 1) || (x % 2) == 0 || (y % 2) == 0) {
					setTile(Point(x, y), OBSTACLE);
				}
			}
		}
		
		points = new Stack!(Point)();
	}
	
	override bool solved(Point p) {
		// Only solved when all points with even x- and y- coordinates have been visited
		for(int x = 0; x < size.width; x++) {
			for(int y = 0; y < size.height; y++) {
				if(x % 2 == 1 && y % 2 == 1 && tileAt(Point(x, y)) == UNVISITED) {
					return false;
				}
			}
		}
		return true;
	}

	override bool visitable(Point p) {
		return inBounds(p) && (tileAt(p) == UNVISITED);
	}
	
	override Point[] searchOperator(Point p) {
		auto moves = movesFrom(p);
		
		auto heap = new LeftHeap!(Point)();
		// Randomize order of moves
		foreach(m; moves) {
			heap.insert(rand(), m);
		}
		
		return heap.toArray();
	}
	
	override void visit(Point p) {
		if(moves.length > 1) {
			// Clear wall between lastPoint and this point
			auto thisMove = moves.pop();
			auto lastPoint = moves.peek();
			moves.push(thisMove);
			auto wall = Point((lastPoint.x - p.x) / 2 + p.x, (lastPoint.y - p.y) / 2 + p.y);
			setTile(wall, UNVISITED);
		}
		points.push(p);
		setTile(p, curTurn++);
	}
	
	override void preDrawFrame(Canvas c, int frameNum) { }
	
	override void postDrawFrame(Canvas c,int frameNum) { }
	
	override void drawTile(Canvas c, Point p, Point ul, Point lr, int frameNum) {
		auto color = (tileAt(p) == OBSTACLE ? Color(0.0, 0.0, 0.0) : Color(1.0, 1.0, 1.0));
		c.drawRectangle(new util.point.Point(ul.x, ul.y), new util.point.Point(lr.x, lr.y), Color(0.0, 0.0, 0.0), color);
	}
}
/*
void main() {
	int width;
	int height;
	
	writef("Enter width height: ");
	scanf("%d %d", &width, &height);
	auto mazegen = new MazeGen(new Size(width, height));
	mazegen.search(mazegen.start);
	mazegen.visualize();
}*/
