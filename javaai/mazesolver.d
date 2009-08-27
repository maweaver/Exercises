import std.random;
import std.stdio;
import std.c.stdio;

import util.maze;
static import util.point;
import util.size;
import util.visualizer;

import mazegen;

class DepthMaze :
Maze {
	private:
	
	int curDepth = 0;
	
	public:
	
	this(Size inSize) {
/*		auto mazegen = new MazeGen(inSize);
		mazegen.depthSearch(mazegen.start);*/
		
		super(inSize, Point(1, 1), Point(inSize.iwidth - 2, inSize.iheight - 2),
			[ Point(-1, 0), Point(0, -1), Point(1, 0), Point(0, 1) ],
			"Depth-First Maze", 1000);
		/*
		for(int x = 0; x < size.width; x++) {
			for(int y = 0; y < size.height; y++) {
				auto p = new Point(x, y);
				if(mazegen.tileAt(p) == OBSTACLE) {
					setTile(p, OBSTACLE);
				}
			}
		}*/
	}
	
	override int numFrames() {
		return 1;
	}
	
	override bool visitable(Point p) {
		return inBounds(p) && tileAt(p) == UNVISITED;
	}
	
	override Point[] searchOperator(Point p) {
		return movesFrom(p);
	}
	
	override void visit(Point p) {
		curDepth++;
		setTile(p, curDepth);
		
		if(solved(p)) {
			for(int x = 0; x < size.width; x++) {
				for(int y = 0; y < size.height; y++) {
					auto point = Point(x, y);
					auto v = tileAt(point);
					if(v > 0) {
						if(moves.indexOf(point) > -1) {
							setTile(point, 1);
						} else {
							setTile(point, 0);
						}
					}
				}
			}
		}	
	}
	
	override void preDrawFrame(Canvas c, int frameNum) { 	}
	
	override void postDrawFrame(Canvas c, int frameNum) { }
	
	override void drawTile(Canvas c, Point p, Point ul, Point lr, int frameNum) {
		auto val = tileAt(p);
		auto textSize = 24;
		auto moveIdx = moves.indexOf(p);
		
		Color bgColor;
		if(val == OBSTACLE) {
			bgColor = Color(0.0, 0.0, 0.0);
		} else if(val != UNVISITED && moveIdx == -1) {
			bgColor = Color(0.0, 0.1, 0.7);
		} else if(val != UNVISITED && moveIdx != -1) {
			bgColor = Color(0.0, 0.7, 0.1);
		} else {
			bgColor = Color(1.0, 1.0, 1.0);
		}
		
		c.drawRectangle(new util.point.Point(ul.x, ul.y), new util.point.Point(lr.x, lr.y), Color(0.0, 0.0, 0.0), bgColor);
		
		if(p == start) {
			c.drawCenteredText("S", new util.point.Point(ul.x, ul.y), new util.point.Point(lr.x, lr.y), textSize, "Sans", FontSlant.Normal, FontWeight.Normal,
				Color(0.0, 0.0, 0.7));
		} else if(p == goal) {
			c.drawCenteredText("G", new util.point.Point(ul.x, ul.y), new util.point.Point(lr.x, lr.y), textSize, "Sans", FontSlant.Normal, FontWeight.Normal,
				Color(0.7, 0.0, 0.0));
		}/* else if(moveIdx != -1) {
			c.drawCenteredText(std.string.toString(moveIdx), ul, lr, textSize);
		}*/
	}
	
}

void main() {
	int width;
	int height;
	
	scanf("%d %d\n", &width, &height);
	auto board = new DepthMaze(new Size(width, height));

	for(int y = 0; y < height; y++) {
		auto line = readln();
		for(int x = 0; x < width; x++) {
			auto val = 0;
			auto ch = line[x * 2];
			if(ch == '#') {
				val = -2;
			}
			board.setTile(Point(x, y), val);
		}
	}
	
	board.breadthSearch(board.start);
//	board.visualize();
/*	int width;
	int height;
	int algo;
	
	writef("Enter width height algo [0 for recursive depth-first search, 1 for iterative depth-first search, 2 for iterative breadth-first search, 3 for recursive breadth-first search]: ");
	scanf("%d %d %d", &width, &height, &algo);
	
	auto board = new DepthMaze(new Size(width, height));
	switch(algo) {
		case 0:
			writefln("Recursive depth-first");
			board.depthSearchRecursive(board.start);
			break;
			
		case 1:
			writefln("Iterative depth-first");
			board.depthSearch(board.start);
			break;
			
		case 2:
			writefln("Iterative breadth-first");
			board.breadthSearch(board.start);
			break;
			
		case 3:
			writefln("Recursive breadth-first");
			board.breadthSearchRecursive(board.start);
			break;
	}
	//board.visualize();
	for(int y = 0; y < board.size.height; y++) {
		for(int x = 0; x < board.size.width; x++) {
			if(board.tileAt(new Point(x, y)) == -2) {
				writef("##");
			} else if(board.tileAt(new Point(x, y)) > 0) {
				writef("--");
			} else {
				writef("  ");
			}
		}
		writefln();
	}*/
}
