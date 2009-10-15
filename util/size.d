module util.size;

import std.conv;
import std.math;

/++
 + A size, consisting of a width and a height
 +/
class Size {
	private:
	
	double _width;
	double _height;
	
	public:
	
	/++
	 + Tolerance used to determine whether two points match
	 +/
	static double tolerance = 0.000001;
	
	/++	
	 + Constructor
	 +/
	this(double width, double height) {
		_width = width;
		_height = height;
	}
	
	/++
	 + The width
	 +/
	double width() {
		return _width;
	}
	
	/++
	 + The height
	 +/
	double height() {
		return _height;
	}
	
	/++
	 + The width, cast as an int
	 +/
	int iwidth() {
		return cast(int) width;
	}
	
	/++
	 + The height, cast as an int
	 +/
	int iheight() {
		return cast(int) height;
	}
	
	/++
	 + Adds two sizes
	 +/
	Size opAdd(Size s) {
		return new Size(width + s.width, height + s.height);
	}
	
	/++
	 + Subtracts a size from another
	 +/
	Size opSub(Size s) {
		return new Size(width - s.width, height - s.height);
	}
	
	/++
	 + Multiplies a size by a scalar
	 +/
	Size opMul(double val) {
		return new Size(width * val, height * val);
	}
	
	/++
	 + Divides a size by a scalar
	 +/
	Size opDiv(double val) {
		return new Size(width / val, height / val);
	}

  /++
   + 0 if the two sizes do not represent the same size
	 +/
	bool opEquals(Object o) {
		Size op = cast(Size) o;
		if(op) {
			return abs(op.width - _width) < tolerance && 
			  abs(op.height - _height) < tolerance;
		} else {
			return false;
		}
	}
	
	/++
	 + Gets the string representation of this size
	 +/
	string toString() {
		return to!(string)(width) ~ "x" ~ to!(string)(height);
	}
}
