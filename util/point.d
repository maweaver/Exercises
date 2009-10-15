module util.point;

import std.conv;
import std.math;

/++
 + A 2-dimensional point, consisting of an X and Y coordinate.  This can also be
 + used as a vector, as the arithmetic is the same.
 +/
class Point {
	private:
		
	double _x;
	double _y;
		
	public:
	
	/++
	 + Tolerance used to determine whether two points match
	 +/
	static double tolerance = 0.000001;
	
	/++	
	 + Constructor
	 +/
	this(double x, double y) {
		_x = x;
		_y = y;
	}
	
	/++
	 + The x coordinate
	 +/
	double x() {
		return _x;
	}
	
	/++
	 + The y coordinate
	 +/
	double y() {
		return _y;
	}
	
	/++
	 + The x coordinate, cast as an int
	 +/
	int ix() {
		return cast(int) x;
	}
	
	/++
	 + The y coordinate, cast as an int
	 +/
	int iy() {
		return cast(int) y;
	}
	
	/++
	 + Adds two points
	 +/
	Point opAdd(Point p) {
		return new Point(x + p.x, y + p.y);
	}
	
	/++
	 + Subtracts a point from another
	 +/
	Point opSub(Point p) {
		return new Point(x - p.x, y - p.y);
	}
	
	/++
	 + Negates a point
	 +/
	Point opNeg() {
		return new Point(-x, -y);
	}
	
	/++
	 + Multiplies a point by a scalar
	 +/
	Point opMul(double val) {
		return new Point(x * val, y * val);
	}
	
	/++
	 + Divides a point by a scalar
	 +/
	Point opDiv(double val) {
		return new Point(x / val, y / val);
	}

  /++
   + 0 if the two points do not represent the same location in space
	 +/
	bool opEquals(Object o) {
		Point op = cast(Point) o;
		if(op) {
			return abs(op.x - _x) < tolerance && 
			  abs(op.y - _y) < tolerance;
		} else {
			return false;
		}
	}
	
	/++
	 + Gets the string representation of this point
	 +/
	string toString() {
		return "(" ~ to!(string)(x) ~ ", " ~ to!(string)(y) ~ ")";
	}

}

