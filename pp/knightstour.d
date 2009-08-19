import std.stdio;
import std.c.stdio;
import visualizer;

class KnightsTourFrameData: FrameData {
	Board board;
			
	this(Board board) {
		this.board = board;
	}
}
		
class Point {
	private:
		
	int _x;
	int _y;
		
	public:
		
	this(int x, int y) {
		_x = x;
		_y = y;
	}
		
	int x() {
		return _x;
	}
	
	int y() {
		return _y;
	}
		
	int opEquals(Object o) {
		Point op = cast(Point) o;
		if(op) {
			return op.x == _x && op.y == _y;
		} else {
			return 0;
		}
	}
		
	Point opAdd(Point p) {
		return new Point(x + p.x, y + p.y);
	}
}

class Board {
	
	private:
	
	int _size;
	int[][] _tiles;
	Point[] _perms;

	bool canVisit(int n, Point p) {
		return p.x >= 0 && p.x < _size &&
		       p.y >= 0 && p.y < _size &&
					 ((n == (_size * _size + 1) && _tiles[p.x][p.y] == 1) ||
						 _tiles[p.x][p.y] == 0);
	}
	
	Point[] movesFrom(int n, Point p) {
		Point[] res;
		
		foreach(perm; _perms) {
			auto moveP = p + perm;
			if(canVisit(n, moveP)) {
				res ~= moveP;
			}
		}
		
		return res;
	}	
	
	bool visit(int n, Point p, Point[] moves) {
		if(n == (_size * _size + 1)) {
			
			if(_tiles[p.x][p.y] == 1) {
				visualizeSolution();
			}
			
			return true;
		} else {
			
			_tiles[p.x][p.y] = n;
		
			Point[][Point] nextNextMoves;
			foreach(m; moves) {
				nextNextMoves[m] = movesFrom(n + 2, m);
			}
		
			Point[] orderedMoves;
			for(int i = 0; i < 8; i++) {
				foreach(p, m; nextNextMoves) {
					if(m.length == i) {
						orderedMoves ~= p;
					}
				}
			}

			foreach(nextMove; orderedMoves) {
				if(visit(n + 1, nextMove, nextNextMoves[nextMove])) {
					return true;
				}
			}
		
			_tiles[p.x][p.y] = 0;
			
			return false;
		}
	}
	
	void visualizeSolution() {
		auto frames = new FrameData[1];
		frames[0] = new KnightsTourFrameData(this);
		createVisualization("Knights Tour", &drawFunction, 1000, frames, _size * _size  + 2, Size(_size * 64, _size * 64));
	}
	
	static void drawFunction(Canvas c, int frameNum, FrameData frameData) {
		auto kdFrameData = cast(KnightsTourFrameData) frameData;
		if(kdFrameData) {
			auto size = kdFrameData.board._size;
			
			c.logicalWidth = size * 64 + 20;
			c.logicalHeight = size * 64 + 20;
			c.useWindowCoordinates();
			
			Point prevPoint;
			Point thisPoint;
			
			for(int i = 0; i < size; i++) {
				for(int j = 0; j < size; j++) {
					Color color;
					
					if((i % 2 == 0 && j % 2 == 0) || 
						(i % 2 == 1 && j % 2 == 1)) {
					
					  color = Color(1.0, 1.0, 1.0);
					
					} else {
						color = Color(0.5, 0.5, 0.5);
					}
					
					c.drawRectangle(visualizer.Point(i * 64 + 10, j * 64 + 10), Size(64, 64),
						Color(0.0, 0.0, 0.0), color);
					
					auto turnNum = kdFrameData.board._tiles[i][j];
					
					if(turnNum < frameNum) {
						c.drawLine(visualizer.Point(i * 64 + 14, j * 64  + 14), 
							visualizer.Point((i + 1) * 64 + 6, (j + 1) * 64 + 6),
							Color(0.7, 0.0, 0.0), 4.0);
						c.drawLine(visualizer.Point(i * 64 + 14, (j + 1) * 64  + 6), 
							visualizer.Point((i + 1) * 64 + 6, j * 64 + 14),
							Color(0.7, 0.0, 0.0), 4.0);
						if(turnNum == frameNum - 1) {
							prevPoint = new Point(i, j);
						}
					} else if(turnNum == frameNum) {
						c.drawCircle(visualizer.Point(i * 64 + 14, j * 64 + 14),
							visualizer.Point((i + 1) * 64 + 6, (j + 1) * 64 + 6),
							Color(0.0, 0.0, 0.0),
							Color(0.0, 0.0, 0.7));
						
						thisPoint = new Point(i, j);
					}
				}
			}
		}
	}

	public:
	
	this(int size) {
		_size = size;
		_tiles = new int[][](size, size);
		
		_perms = [ new Point(-1, -2), new Point(+1, -2), 
		           new Point(+2, -1), new Point(+2, +1),
							 new Point(+1, +2), new Point(-1, +2),
							 new Point(-2, -1), new Point(-2, +1) ];
	}
	
	bool tour(Point start) {
		return visit(1, start, movesFrom(1, start));
	}
}

void main() {
	int boardSize;
	int startX;
	int startY;
	
	scanf("%d %d %d", &boardSize, &startX, &startY);
	
	if(!(new Board(boardSize)).tour(new Point(startX, startY))) {
		writefln("No solution found!");
	}
}
