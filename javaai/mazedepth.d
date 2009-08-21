import std.random;
import std.stdio;
import std.c.stdio;

import util.maze;
import util.point;
import util.size;
import util.visualizer;

class DepthMaze :
Maze {
	private:
	
	int UNVISITED = 0;
	int VISITED = -1;
	int OBSTACLE = -2;
	
	int curDepth = 0;
	
	public:
	
	this(Size size, int pctObstacles) {
		super(size, new Point(0, 0), new Point(size.iwidth - 1, size.iheight - 1),
			[ new Point(-1, 0), new Point(0, -1), new Point(1, 0), new Point(0, 1) ],
			"Depth-First Maze", 1000);
		
		for(int x = 0; x < size.width; x++) {
			for(int y = 0; y < size.height; y++) {
				if(x != size.iwidth && y != size.iheight && rand() % 100 < pctObstacles) {
					setTile(new Point(x, y), OBSTACLE);
				}
			}
		}
	}
	
	override int numFrames() {
		return curDepth;
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
	}
	
	override void unvisit(Point p) {
	}
	
	override void preDrawFrame(Canvas c, int frameNum) { }
	
	override void postDrawFrame(Canvas c, int frameNum) { }
	
	override void drawTile(Canvas c, Point p, Point ul, Point lr, int frameNum) {
		auto val = tileAt(p);
		auto textOffset = new Point(15, 50);
		auto textSize = 32;
		
		Color bgColor;
		if(val == OBSTACLE) {
			bgColor = Color(0.5, 0.5, 0.5);
		} else {
			bgColor = Color(1.0, 1.0, 1.0);
		}
		
		c.drawRectangle(ul, lr, Color(0.0, 0.0, 0.0), bgColor);
		
		if(p == start) {
			c.drawText("S", ul + textOffset, textSize, "Sans", FontSlant.Normal, FontWeight.Normal,
				Color(0.0, 0.7, 0.0));
		} else if(p == goal) {
			c.drawText("G", ul + textOffset, textSize, "Sans", FontSlant.Normal, FontWeight.Normal,
				Color(0.7, 0.0, 0.0));
		} else if(val != OBSTACLE && (val - 2) < frameNum && val != 0) {
			c.drawText(std.string.toString(val), ul + textOffset, textSize);
		}
	}
	
}

void main() {
	int width;
	int height;
	int pctObstacles;
	
	writef("Enter width height percentObstacles: ");
	scanf("%d %d %d", &width, &height, &pctObstacles);
	
	auto board = new DepthMaze(new Size(width, height), pctObstacles);
	if(!board.search(board.start)) {
		writefln("Sorry, unsolvable");
	} else {
		board.visualize();
	}
}
