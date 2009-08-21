import std.stdio;
import std.c.stdio;
import util.leftheap;
import util.maze;
import util.point;
import util.size;
import util.visualizer;

class ChessBoard: Maze {
	
	private:
	
	Point[] perms;
	int curTurn;
	
	public:
	
	this(int size, Point start) {
		super(new Size(size, size), start, start, 
			[ new Point(-1, -2), new Point(+1, -2), 
        new Point(+2, -1), new Point(+2, +1),
				new Point(+1, +2), new Point(-1, +2),
				new Point(-2, -1), new Point(-2, +1) ],
			"Knights Tour", size * size + 2, 1000);
	}
	
	int finalTurn() {
		return size.iwidth * size.iheight;
	}
	
	override bool solved(Point p) {
		return curTurn == finalTurn && p == goal;
	}
	
	override bool visitable(Point p) {
		return p.x >= 0 && p.x < size.width &&
		       p.y >= 0 && p.y < size.height &&
					 (tileAt(p) == 0 || (p == start && curTurn == finalTurn));
	}
	
	override Point[] searchOperator(Point p) {
		// Use a minimum heap to return the moves with the least number of possible
		// next moves first
		auto moves = new LeftHeap!(Point)(true);
		
		auto possibleMoves = movesFrom(p);
		foreach(move; possibleMoves) {
			moves.insert(movesFrom(move).length, move);
		}
		
		return moves.toArray();
	}	
	
	override void visit(Point p) {
		curTurn++;
		setTile(p, curTurn);
	}
	
	override void unvisit(Point p) {
		curTurn--;
		setTile(p, 0);
	}
	
	override void preDrawFrame(Canvas c, int frameNum) {
	}
	
	override void postDrawFrame(Canvas c, int frameNum) {
		Point thisPoint;
		Point prevPoint;
		
		for(int x = 0; x < size.width; x++) {
			for(int y = 0; y < size.height; y++) {
				auto p = new Point(x, y);
				auto tile = tileAt(p);
				if(tile == frameNum) {
					thisPoint = p;
				} else if(tile == frameNum - 1) {
					prevPoint = p;
				}
			}
		}
		
		if(thisPoint && prevPoint) {
			auto thisVizPoint = new Point(thisPoint.x * vizScale + vizScale / 2 + vizBorder, thisPoint.y * vizScale + vizScale / 2 + vizBorder);
			auto prevVizPoint = new Point(prevPoint.x * vizScale + vizScale / 2 + vizBorder, prevPoint.y * vizScale + vizScale / 2 + vizBorder);
			c.drawLine(
				thisVizPoint,
				new Point(prevVizPoint.x, thisVizPoint.y),
				Color(0.0, 0.3, 0.8, 0.7), 5.0);
			c.drawLine(
				new Point(prevVizPoint.x, thisVizPoint.y),
				prevVizPoint,
				Color(0.0, 0.3, 0.8, 0.7), 5.0);
		}
	}
	
	override void drawTile(Canvas c, Point p, Point ul, Point lr, int frameNum) {
		auto turnNum = tileAt(p);
				
		Color color;
		if(turnNum == 1) {
				color = Color(0.0, 0.8, 0.3);
		} else if((p.x % 2 == 0 && p.y % 2 == 0) || 
			        (p.x % 2 == 1 && p.y % 2 == 1)) {
		  color = Color(1.0, 1.0, 1.0);
		} else {
			color = Color(0.5, 0.5, 0.5);
		}

		c.drawRectangle(ul, lr, Color(0.0, 0.0, 0.0), color);
					
		if(turnNum < frameNum && turnNum != 1) {
			c.drawLine(ul + new Point(4, 4), lr - new Point(4, 4),
				Color(0.7, 0.0, 0.0), 4.0);
			c.drawLine(ul + new Point(vizScale - 4, 4), lr - new Point(vizScale - 4, 4),
				Color(0.7, 0.0, 0.0), 4.0);
		} else if(turnNum == frameNum || (turnNum == 1 && frameNum == (size.width * size.height + 1))) {
			c.drawCircle(ul + new Point(4, 4), lr - new Point(4, 4),
				Color(0.0, 0.0, 0.0), Color(0.0, 0.0, 0.7));
		}		
	}
}

void main() {
	int boardSize;
	int startX;
	int startY;
	
	writef("Enter board size then start x then start y: ");
	scanf("%d %d %d", &boardSize, &startX, &startY);
	
	auto board = new ChessBoard(boardSize, new Point(startX, startY));
	board.search(board.start);
	board.visualize();
}
