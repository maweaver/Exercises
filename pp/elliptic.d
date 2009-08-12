import std.math;
import std.stdio;
import std.string;

import wrappedint;

/++
 + A point on an elliptic curve whose points are ranged integers.  Supports
 + algebraic manipulation with other points on the same curve.
 +/
class IntEllipticCurvePoint {
	
	private:
	
	WrappedInt _x;
	WrappedInt _y;
	IntEllipticCurve _curve;
	bool _inf;
	
	public:
	
	/++
	 + Constructor.
	 +/
	this(WrappedInt x, WrappedInt y, IntEllipticCurve curve, bool inf) {
		_x = x;
		_y = y;
		_curve = curve;
		_inf = inf;
	}
	
	/++
	 + Constructor.  Assumes the point is not infinity.
	 +/
	this(WrappedInt x, WrappedInt y, IntEllipticCurve curve) {
		this(x, y, curve, false);
	}
	
	/++
	 + Returns the x-coordinate of this point
	 +/
	WrappedInt x() {
		return _x;
	}
	
	/++
	 + Returns the y-coordinate of this point.
	 +/
	WrappedInt y() {
		return _y;
	}
	
	/++
	 + Adds two points together, returning the point representing their sum.
	 +/
	IntEllipticCurvePoint opAdd(IntEllipticCurvePoint p2) {
		auto p1 = this;
		WrappedInt s;
		
		if(this == _curve.inf) {
			return p2;
		} else if(p2 == _curve.inf) {
			return this;
		} else if(p1.x == p2.x && p1.y != p2.y) {
			return _curve.inf;
		} else if(p1.x == p2.x && p1.y == p2.y) {
			s = (3 * p1.x.square() + _curve.a) / (2 * p1.y);
		} else {
			s = (p1.y - p2.y) / (p1.x - p2.x);
		}
		
		auto x3 = s.square() - p1.x - p2.x;
		auto y3 = -p1.y + s * (p1.x - x3);

		return new IntEllipticCurvePoint(x3, y3, _curve);
	}
	
	/++
	 + Compares two points for equality.  Two points are the same if they lie
	 + along the same curve and have equal x and y values.
	 +/
	int opEquals(Object o) {
		auto iecpo = cast(IntEllipticCurvePoint) o;
		if(iecpo) {
			return iecpo._curve == _curve && iecpo.x == x && iecpo.y == y;
		} else {
			return 0;
		}
	}
	
	/++
	 + Returns the negative of this point, which is the point with the same x
	 + value but an opposite y value.
	 +/
	IntEllipticCurvePoint opNeg() {
		return new IntEllipticCurvePoint(x, -y, _curve);
	}
	
	/++
	 + Multiplies the current point by an int
	 +/
	IntEllipticCurvePoint opMul(int amount) {
		IntEllipticCurvePoint res = _curve.inf;
		
		for(int i = 0; i < amount; i++) {
			res = res + this;
		}
		
		return res;
	}
	
	/++
	 + Returns a pretty representation of the point.
	 +/
	char[] toString() {
		if(_inf) {
			return "O";
		} else {
			return "(" ~ std.string.toString(x.val) ~ ", " ~ std.string.toString(y.val) ~ ")";
		}
	}
}

/++
 + An elliptic curve evaluated over a set of discrete integer values between
 + 0 and k.  The curve is described by the function y^2 = x^3 + ax + b.  It also
 + contains a point inf, which is the identity value for addition.
 +/
class IntEllipticCurve {
	private:
	
	IntEllipticCurvePoint[][] _points;
	IntEllipticCurvePoint _inf;
	int _k;
	int _a;
	int _b;
	
	public:
	
	/++
	 + Constructor
	 +/
	this(uint a, uint b, int k) {
		_a = a;
		_b = b;
		_k = k;
		_inf = new IntEllipticCurvePoint(new WrappedInt(0, k), new WrappedInt(0, k), this, true);
		
		_points.length = k;
		for(int x = 0; x < k; x++) {
			auto wix = new WrappedInt(x, k);
			auto ySquared = wix.pow(3) + wix * a + b;
			if(ySquared.val == 0) {
				_points[x] = new IntEllipticCurvePoint[1];
				_points[x][0] = new IntEllipticCurvePoint(wix, ySquared, this);
			} else {
				try {
					auto ys = ySquared.sqrt();
					_points[x] = new IntEllipticCurvePoint[2];
					_points[x][0] = new IntEllipticCurvePoint(wix, ys[0], this);
					_points[x][1] = new IntEllipticCurvePoint(wix, ys[1], this);
				} catch(Exception) {
					// Do nothing... this just means there are no y's for this x
				}
			}
		}
	}
	
	/++
	 + The term by which x is multiplied
	 +/
	int a() {
		return _a;
	}
	
	/++
	 + The term which is added to x
	 +/
	int b() {
		return _b;
	}
	
	/++
	 + The wrapping point for this curve
	 +/
	int k() {
		return _k;
	}
	
	/++
	 + Infinity, or O
	 +/
	IntEllipticCurvePoint inf() {
		return _inf;
	}
	
	/++
	 + The 0, 1, or 2 points at the given x value
	 +/
	IntEllipticCurvePoint[] pointsAt(int x) {
		return _points[x];
	}

	unittest {
		auto curve = new IntEllipticCurve(4, 4, 5);

		// Calculating points on the curve
		auto p1s = curve.pointsAt(1);
		writefln("Points @ x = 1 : (1, 2), (1, 3) [%s, %s]", p1s[0].toString, p1s[1].toString);
		assert(p1s.length == 2);
		assert(p1s[0] == new IntEllipticCurvePoint(new WrappedInt(1, 5), new WrappedInt(2, 5), curve));
		assert(p1s[1] == new IntEllipticCurvePoint(new WrappedInt(1, 5), new WrappedInt(3, 5), curve));

		auto p2s = curve.pointsAt(2);
		writefln("Points @ x = 2 : (2, 0) [%s]", p2s[0].toString);
		assert(p2s.length == 1);
		assert(curve.pointsAt(2)[0] == new IntEllipticCurvePoint(new WrappedInt(2, 5), new WrappedInt(0, 5), curve));
		
		auto p3s = curve.pointsAt(3);
		writefln("Points @ x = 3 : () []");
		assert(p3s.length == 0);
		
		// Addition
		auto p1 = curve.pointsAt(1)[0];
		auto p2 = curve.pointsAt(4)[1];
		writefln("(1, 2) + (4, 3) = (4, 2) [%s]", (p1 + p2).toString);
		assert(p1 + p2 == new IntEllipticCurvePoint(new WrappedInt(4, 5), new WrappedInt(2, 5), curve));
		
		// Negation
		writefln("-(1, 2) = (1, 3) [%s]", (-p1).toString);
		assert(-p1 == new IntEllipticCurvePoint(new WrappedInt(1, 5), new WrappedInt(3, 5), curve));
		
		// Double
		writefln("2 * (1, 2) = (2, 0) [%s]", (p1 * 2).toString);
		assert(p1 * 2 == new IntEllipticCurvePoint(new WrappedInt(2, 5), new WrappedInt(0, 5), curve));
		
		// Triple
		writefln("3 * (1, 2) = (1, 3) [%s]", (p1 * 3).toString);
		assert(p1 * 3 == new IntEllipticCurvePoint(new WrappedInt(1, 5), new WrappedInt(3, 5), curve));

		// Quadruple
		writefln("4 * (1, 2) = O [%s]", (p1 * 4).toString);
		assert(p1 * 4 == curve.inf);

		// Quintuple
		writefln("5 * (1, 2) = (1, 2) [%s]", (p1 * 5).toString);
		assert(p1 * 5 == new IntEllipticCurvePoint(new WrappedInt(1, 5), new WrappedInt(2, 5), curve));
	}
}

void main() {
}
