module util.visualizer;

import std.math;
import std.stdio;
import std.string;

import util.point;
import util.size;

/++
 + Class containing information on a frame in the visualization.  Purposefully
 + has no fields; designed to be subclassed.
 +/
class FrameData {
}

/++
 + A color with red, green, blue, and alpha channels.
 +/
struct Color {
	double r;        /// Red component
	double g;        /// Green component
	double b;        /// Blue component
	double a = 1.0;  /// Alpha component
}

/++
 + A transformation matrix
 +
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-matrix.html#cairo-matrix-t
 +/
struct Matrix {
	double xx;
	double yx;
	double xy;
	double yy;
	double x0;
	double y0;
}

/++
 + The style used to draw the ends of lines
 +
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-line-cap-t
 +/
enum LineCap {
	Butt,   /// No extra ending to the line
	Round,  /// Rounded cap to the line
	Square  /// Squared cap to the line
}

/++
 + The style used to join lines
 +
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-line-cap-t
 +/
enum LineJoin {
	Miter,  /// Edges are extended to form sharp corners
	Round,  /// Edges are rounded
	Bevel   /// Edges are chopped
}

/++
 + Slant of the font
 +
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-text.html#cairo-font-slant-t
 +/
enum FontSlant {
	Normal,
	Italic,
	Oblique
}

/++
 + Weight of the font
 +
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-text.html#cairo-font-weight-t
 +/
enum FontWeight {
	Normal,
	Bold
}

/++
 + See_Also: 
 +   http://library.gnome.org/devel/cairo/stable/cairo-surface.html#cairo-content-t
 +/
enum Content {
	Color = 0x1000,      /// Surface holds only color content
	Alpha = 0x2000,      /// Surface holds only alpha content
	ColorAlpha = 0x3000  /// Surface holds color and alpha content
}

/++
 + See_Also: 
 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-antialias-t
 +/
enum Antialias {
	Default,  /// Default antialiasing
	None,     /// No antialiasing
	Gray,     /// Single-color antialising
	Subpixel  /// Subpixel antialiasing
}

/++
 + See_Also:
 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-fill-rule-t
 +/
enum FillRule {
	Winding,  /// Takes path direction into account when filling
	EvenOdd   /// Does not take orientation into account when filling
}

/++
 + See_Also:
 +   http://cairographics.org/operators/
 +/
enum Operator {
	Clear,     /// Clear destination layer
	Source,    /// Replace destination layer
	Over,      /// Draw source on top of destination
	In,        /// Draw source where there was destination
	Out,       /// Draw source where there was no destination
	Atop,      /// Draw source on top of destination
	Dest,      /// Ignore source
	DestOver,  /// Draw destination on top of source
	DestIn,    /// Leave destination only where there was source
	DestOut,   /// Leave destination only where there was no source
	DestAtop,  /// Leave destination on top of source
	Xor,       /// Source and destination are shown where there's only one
	Add,       /// Source and destination are accumulated
	Saturate   /// Assumes source and dest are disjoint
}

struct TextExtents {
	double xBearing;
	double yBearing;
	double width;
	double height;
	double xAdvance;
	double yAdvance;
};


/++
 + All drawing operations are performed via the canvas.  The canvas uses logical coordinates to simplify
 + scaling the image.  By default the logical size is 100x100, with (0, 0) being the center of the screen.  
 + So the far left of the screen is at x = -50, and the right side is at x = +50.
 +/
class Canvas {
	private:
	
	/**************************************
	 * Internal State
	 *************************************/
	
	cairo_t _cr;
	int _imageWidth;
	int _imageHeight;
	
	public:
	
	/**************************************
	 * Constructor
	 *************************************/
	
	/++
	 + Constructor
	 +/
	this(cairo_t cr, int imageWidth, int imageHeight) {
		_cr = cr;
		
		logicalWidth = 100;
		logicalHeight = 100;
		translateX = 0;
		translateY = 0;
		_imageWidth = imageWidth;
		_imageHeight = imageHeight;
	}
	
	/**************************************
	 * Properties
	 *************************************/
	
	/++
	 + The logical width of the image.
	 +/
	int logicalWidth;
	
	/++
	 + The logical height of the image
	 +/
	int logicalHeight;
	
	/++
	 + X Translation
	 +/
	double translateX;
	
	/++
	 + Y Translation
	 +/
	double translateY;
	
	/++
	 + The physical width of the image
	 +/
	int imageWidth() { 
		return _imageWidth; 
	}
	
	/++
	 + The physical height of the image
	 +/
	int imageHeight() { 
		return _imageHeight; 
	}
	
	/**************************************
	 * Base Cairo functions
	 *************************************/
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-save
	 +/
	void cairoSave() {
		cairo_save(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-restore
	 +/
	void cairoRestore() {
		cairo_restore(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-push-group
	 +/
	void cairoPushGroup() {
		cairo_push_group(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-push-group-with-content
	 +/
	void cairoPushGroupWithContent(Content content) {
		cairo_push_group_with_content(_cr, content);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-pop-group
	 +/
	Pattern cairoPopGroup() {
		return cairo_pop_group(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-pop-group-to-source
	 +/
	void cairoPopGroupToSource() {
		cairo_pop_group_to_source(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-source-rgb
	 +/
	void cairoSetSourceRgb(Color color) {
		cairo_set_source_rgb(_cr, color.r, color.g, color.b);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-source-rgba
	 +/
	void cairoSetSourceRgba(Color color) {
		cairo_set_source_rgba(_cr, color.r, color.g, color.b, color.a);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-source
	 +/	
	void cairoSetSource(Pattern source) {
		cairo_set_source(_cr, source);
	}
	 
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-get-source
	 +/	
	Pattern cairoGetSource() {
		return cairo_get_source(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-antialias
   +/
	void cairoSetAntialias(Antialias a) {
		cairo_set_antialias(_cr, a);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-dash
   +/
	void cairoSetDash(double[] dash) {
		if(dash.length > 0) {
			cairo_set_dash(_cr, &dash[0], dash.length, 0);
		} else {
			cairo_set_dash(_cr, null, 0, 0);
		}
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-fill-rule
	 +/
	void cairoSetFillRule(FillRule fr) {
		cairo_set_fill_rule(_cr, fr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-line-cap
	 +/
	void cairoSetLineCap(LineCap lc) {
		cairo_set_line_cap(_cr, lc);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-line-join
	 +/
	void cairoSetLineJoin(LineJoin lj) {
		cairo_set_line_join(_cr, lj);
	}

	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-line-width
	 +/
	void cairoSetLineWidth(double width) {
		cairo_set_line_width(_cr, width);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-miter-limit
	 +/
	void cairoSetMiterLimit(double lim) {
		cairo_set_miter_limit(_cr, lim);
	}
	
	/++
	 + See_Also
	 +   http://cairographics.org/operators/
	 +/
	void cairoSetOperator(Operator op) {
		cairo_set_operator(_cr, op);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-set-tolerance
	 +/
	void cairoSetTolerance(double tolerance) {
		cairo_set_tolerance(_cr, tolerance);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-fill
	 +/
	void cairoFill() {
		cairo_fill(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-fill-preserve
	 +/
	void cairoFillPreserve() {
		cairo_fill_preserve(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-paint
	 +/
	void cairoPaint() {
		cairo_paint(_cr);
	}	
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-paint-with-alpha
	 +/
	void cairoPaintWithAlpha(double a) {
		cairo_paint_with_alpha(_cr, a);
	}	
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-stroke
	 +/
	void cairoStroke() {
		cairo_stroke(_cr);
	}	

	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-context.html#cairo-stroke-preserve
	 +/
	void cairoStrokePreserve() {
		cairo_stroke_preserve(_cr);
	}
	
	/++
	 + See_Also:
	 +   http://library.gnome.org/devel/cairo/stable/cairo-text.html#cairo-text-extents
	 +/
	TextExtents cairoTextExtents(string str) {
		TextExtents te;
		cairo_text_extents(_cr, toStringz(str), &te);
		return te;
	}
	

	/**************************************
	 * Higher Level Functions
	 *************************************/
	 
	/++
	 + Uses window coordinate system, rather than physical
	 +/
	void useWindowCoordinates() {
		translateX = - cast(real) logicalWidth / 2.0;
		translateY = - cast(real) logicalHeight / 2.0;
	}
	
	/++
	 + Converts a point from its logical coordinates to a physical point on the screen.
	 +/
	Point logicalToImage(Point p) {
		auto scale = fmin(cast(real) imageWidth / cast(real) logicalWidth,
			cast(real) imageHeight / cast(real) logicalHeight);
		
		return new Point((p.x + translateX) * scale + cast(real) imageWidth / 2.0, 
			               (p.y + translateY) * scale + cast(real) imageHeight / 2.0);
	}
	
	/++
	 + Scales a scalar value based on the scale of the image
	 +/
	double scaleScalar(double v) {
		auto scale = fmin(cast(real) imageWidth / cast(real) logicalWidth,
			cast(real) imageHeight / cast(real) logicalHeight);
		
		return v * scale;
	}
	
	/++
	 + Draws a line.
	 +
	 + Params:
	 +   p1 = First point of the line
	 +   p2 = Second point of the line
	 +   color = Color of the line; defaults to black
	 +   width = Width of the line; defaults to 0.5
	 +   lineCap = Style of line capping
	 +   dash = Style of dashes
	 +/
	void drawLine(Point p1, Point p2, 
	              Color color = Color(0.0, 0.0, 0.0), 
	              double width = 0.5,
	              LineCap lineCap = LineCap.Round,
	              double[] dash = []) 
	{
		cairo_set_source_rgba(_cr, color.r, color.g, color.b, color.a);
		cairo_set_line_width(_cr, scaleScalar(width));
		cairo_set_line_cap(_cr, lineCap);
		if(dash.length > 0) {
			cairo_set_dash(_cr, &dash[0], dash.length, 0);
		}
		
		auto ip1 = logicalToImage(p1);
		auto ip2 = logicalToImage(p2);
		
		cairo_move_to(_cr, ip1.x, ip1.y);
		cairo_line_to(_cr, ip2.x, ip2.y);
		cairo_stroke(_cr);		
	}
	
	/++
	 + Draws a circle by specifying the center and a radius
	 +
	 + Params:
	 +   center = Center of the circle
	 +   radius = Radius of the circle
	 +   edgeColor = Color of the circle outline; defaults to black
	 +   fillColor = Color of the fill of the circle; defaults to transparent
	 +   edgeWidth = Width of the edge; defaults to 0.5
	 +   edgeDash = Style of dashes for outside line
	 +/
	void drawCircle(Point center, double radius, 
	                Color edgeColor = Color(0.0, 0.0, 0.0, 1.0), 
	                Color fillColor = Color(0.0, 0.0, 0.0, 0.0), 
	                double edgeWidth = 0.5,
	                double[] edgeDash = []) 
	{
		cairo_set_source_rgba(_cr, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a);
		cairo_set_line_width(_cr, scaleScalar(edgeWidth));
		if(edgeDash.length > 0) {
			cairo_set_dash(_cr, &edgeDash[0], edgeDash.length, 0);
		}
		
		auto icenter = logicalToImage(center);
		
		cairo_arc(_cr, icenter.x, icenter.y, scaleScalar(radius), 0, 2 * PI);
		cairo_stroke_preserve(_cr);
		cairo_set_source_rgba(_cr, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
		cairo_fill(_cr);
	}
	
	/++
	 + Draws a circle by specifying the upper-left-hand corner and lower-right-hand corner coordinates.
	 +
	 + Params:
	 +   ul = Coordinate of the upper-left-hand corner of the circle
	 +   lr = Coordinate of the lower-right-hand corner of the circle
	 +   edgeColor = Color of the circle outline; defaults to black
	 +   fillColor = Color of the fill of the circle; defaults to transparent
	 +   edgeWidth = Width of the edge; defaults to 0.5
	 +   edgeDash = Style of dashes for outside line
	 +/
	void drawCircle(Point ul, Point lr,
		Color edgeColor = Color(0.0, 0.0, 0.0, 1.0), 
		Color fillColor = Color(0.0, 0.0, 0.0, 0.0), 
		double edgeWidth = 0.5,
		double[] edgeDash = []) 
	{
		cairo_set_source_rgba(_cr, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a);
		cairo_set_line_width(_cr, scaleScalar(edgeWidth));
		if(edgeDash.length > 0) {
			cairo_set_dash(_cr, &edgeDash[0], edgeDash.length, 0);
		}
		
		auto iul = logicalToImage(ul);
		auto ilr = logicalToImage(lr);
		
		auto radius = fmin((ilr.x - iul.x) / 2.0, (ilr.y - iul.y) / 2.0);
		
		cairo_arc(_cr, 
			iul.x + radius, iul.y + radius,
			radius, 
			0, 2 * PI);
		
		cairo_stroke_preserve(_cr);
		cairo_set_source_rgba(_cr, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
		cairo_fill(_cr);
	}
	
	/++
	 + Draws a rectangle by specifying the upper-left-hand corner and the size
	 +
	 + Params:
	 +   ul = Coordinate of the upper-left-hand corner of the circle
	 +   size = Size of the rectangle
	 +   edgeColor = Color of the circle outline; defaults to black
	 +   fillColor = Color of the fill of the circle; defaults to transparent
	 +   edgeWidth = Width of the edge; defaults to 0.5
	 +   edgeDash = Style of dashes for outside line
	 +/
	void drawRectangle(Point ul, Size size,
		Color edgeColor = Color(0.0, 0.0, 0.0, 1.0), 
		Color fillColor = Color(0.0, 0.0, 0.0, 0.0), 
		double edgeWidth = 0.5,
		double[] edgeDash = [],
		LineJoin lineJoin = LineJoin.Round) 
	{
		cairo_set_source_rgba(_cr, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a);
		cairo_set_line_width(_cr, scaleScalar(edgeWidth));
		if(edgeDash.length > 0) {
			cairo_set_dash(_cr, &edgeDash[0], edgeDash.length, 0);
		}
		cairo_set_line_join(_cr, lineJoin);
		
		auto iul = logicalToImage(ul);
		
		cairo_rectangle(_cr, iul.x, iul.y, scaleScalar(size.width), scaleScalar(size.height));
		cairo_stroke_preserve(_cr);
		cairo_set_source_rgba(_cr, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
		cairo_fill(_cr);
	}
	
	/++
	 + Draws a rectangle by specifying the upper-left-hand and lower-right-hand corner coordinates
	 +
	 + Params:
	 +   ul = Coordinate of the upper-left-hand corner of the rectangle
	 +   lr = Coordinate of the lower-right-hand corner of the rectangle
	 +   edgeColor = Color of the circle outline; defaults to black
	 +   fillColor = Color of the fill of the circle; defaults to transparent
	 +   edgeWidth = Width of the edge; defaults to 0.5
	 +   edgeDash = Style of dashes for outside line
	 +/
	void drawRectangle(Point ul, Point lr,
		Color edgeColor = Color(0.0, 0.0, 0.0, 1.0), 
		Color fillColor = Color(0.0, 0.0, 0.0, 0.0), 
		double edgeWidth = 0.5,
		double[] edgeDash = [],
		LineJoin lineJoin = LineJoin.Round) 
	{
		cairo_set_source_rgba(_cr, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a);
		cairo_set_line_width(_cr, scaleScalar(edgeWidth));
		if(edgeDash.length > 0) {
			cairo_set_dash(_cr, &edgeDash[0], edgeDash.length, 0);
		}
		cairo_set_line_join(_cr, lineJoin);
		
		auto iul = logicalToImage(ul);
		auto ilr = logicalToImage(lr);
		
		cairo_rectangle(_cr, iul.x, iul.y, ilr.x - iul.x,  ilr.y - iul.y);
		cairo_stroke_preserve(_cr);
		cairo_set_source_rgba(_cr, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
		cairo_fill(_cr);
	}
	
	/++
	 + Draws some text
	 +
	 + Params:
	 +   text = Text to draw
	 +   loc = Location to draw at
	 +   size = Size of the text
	 +   family = Font family
	 +   slant = Font slant
	 +   weight = Font weight
	 +   color = Color to draw the text
	 +/
	void drawText(string text, Point loc,
		int size, string family = "Sans",
		FontSlant slant = FontSlant.Normal, FontWeight weight = FontWeight.Normal,
		Color color = Color(0.0, 0.0, 0.0, 1.0)) 
	{
		auto iloc = logicalToImage(loc);
		
		cairo_set_source_rgba(_cr, color.r, color.g, color.b, color.a);
		cairo_move_to(_cr, iloc.x, iloc.y);
		cairo_select_font_face(_cr, toStringz(family), slant, weight);
		cairo_set_font_size(_cr, scaleScalar(size));
		cairo_show_text(_cr, toStringz(text));
	}
	
	void drawCenteredText(string text, Point ul, Point lr,
		int size, string family = "Sans",
		FontSlant slant = FontSlant.Normal, FontWeight weight = FontWeight.Normal,
		Color color = Color(0.0, 0.0, 0.0, 1.0)) 
	{
		cairo_set_source_rgba(_cr, color.r, color.g, color.b, color.a);
		cairo_select_font_face(_cr, toStringz(family), slant, weight);
		cairo_set_font_size(_cr, scaleScalar(size));
		
		auto iul = logicalToImage(ul);
		auto ilr = logicalToImage(lr);
		auto extents = cairoTextExtents(text);
		auto textSize = new Size(ilr.x - iul.x, ilr.y - iul.y);
		auto gapSize = new Size((textSize.width - (extents.width)) / 2.0, (textSize.height - (extents.height)) / 2.0);
		auto offset = new Point(iul.x + gapSize.width - extents.xBearing, iul.y + gapSize.height - extents.yBearing);
		cairo_move_to(_cr, offset.x, offset.y);
		cairo_show_text(_cr, toStringz(text));
	}
	
	/++
	 + Fills the canvas with a solid color.
	 +
	 + Params:
	 +   color = Color to fill with
	 +/
	void fill(Color color) {
		drawRectangle(new Point(- cast(real) logicalWidth / 2.0, - cast(real) logicalHeight / 2.0),
			new Size(logicalWidth, logicalHeight),
			color, color);
	}
}


/++
 + A callback function which does the drawing.
 +/
typedef void function(Canvas, int, FrameData) DrawFunction;

class DrawingInfo {
	public:
	
	gpointer win;
	DrawFunction fn;
	FrameData[] frames;
	int numFrames;
	int curFrame;
	bool paused;
}

extern(C) {
	void *visualization_draw_handler(gpointer w, gpointer e, gpointer data) {
		auto info = *(cast(DrawingInfo*) data);	

		int width;
		int height;
		gdk_drawable_get_size(gtk_widget_get_window(w), &width, &height);
		
		auto context = gdk_cairo_create(gtk_widget_get_window(w));
		cairo_rectangle(context, 0, 0, width, height);
		cairo_clip(context);
		
		auto surface = cairo_get_target(context);
	
		info.fn(new Canvas(context, width, height), info.curFrame, info.frames[cast(int) fmin(info.curFrame, info.frames.length - 1)]);
	
		cairo_destroy(context);
		return null;
	}	
	
	int visualization_timeout_handler(gpointer data) {
		auto info = *(cast(DrawingInfo*) data);
		if(info.paused) {
			return 0;
		}
		if(info.curFrame < info.numFrames - 1) {
			info.curFrame += 1;
			int width;
			int height;
			gdk_drawable_get_size(gtk_widget_get_window(info.win), &width, &height);
			gtk_widget_queue_draw_area(info.win, 0, 0, width, height);
			return 1;
		} else {
			return 0;
		}
	}
	
	int visualization_keypress_handler(gpointer widget, GdkKeyEvent *event, gpointer data)  {
		auto info = *(cast(DrawingInfo*) data);
		if(event.keyval == 65361 && info.curFrame > 0) {
			info.paused = true;
			info.curFrame -= 1;
			int width;
			int height;
			gdk_drawable_get_size(gtk_widget_get_window(info.win), &width, &height);
			gtk_widget_queue_draw_area(info.win, 0, 0, width, height);
		} else if (event.keyval == 65363 && info.curFrame < info.numFrames - 1) {
			info.paused = true;
			info.curFrame += 1;
			int width;
			int height;
			gdk_drawable_get_size(gtk_widget_get_window(info.win), &width, &height);
			gtk_widget_queue_draw_area(info.win, 0, 0, width, height);
		}
		
		return 0;
	}
}

/++
 + Creates a drawing
 +
 + Params:
 +   title = Title of the drawing
 +   fn = Function used to perform the drawing
 +   size = Initial drawing size
 +/
 void createVisualization(string title, DrawFunction fn, int frameLength, FrameData[] frames = [ new FrameData() ], int numFrames = 1, Size size = new Size(200, 200)) {
	gtk_init(0, null);
	
	auto window = gtk_window_new(0);
	auto da = gtk_drawing_area_new();

	auto info = new DrawingInfo();
	info.win = da;
	info.fn = fn;
	info.frames = frames;
	info.numFrames = numFrames;
	info.curFrame = 0;
	
	gtk_widget_add_events(window, 1 << 10);
	g_signal_connect_data(da, toStringz("expose-event"), cast(gpointer) &visualization_draw_handler, cast(gpointer) &info, null, 0);
	g_signal_connect_data(window, toStringz("key-press-event"), cast(gpointer) &visualization_keypress_handler, cast(gpointer) &info, null, 0);
	g_signal_connect_data(window, toStringz("destroy"), cast(gpointer) &gtk_main_quit, null, null, 0);
	gtk_container_add(window, da);
	
	gtk_window_set_title(window, toStringz(title));
	gtk_window_set_default_size(window, cast(int) size.width, cast(int) size.height);
	
	g_timeout_add(frameLength, cast(gpointer) &visualization_timeout_handler, cast(gpointer) &info);
	
	gtk_widget_show_all(window);
	gtk_main();
}

extern(C) {
	// Basic types
	typedef void *gpointer;
	typedef void *cairo_t;
	typedef void *cairo_surface_t;
	typedef void *Pattern; /// A pattern used to draw with
	
	struct GdkKeyEvent {
		int type;
		gpointer window;
		byte send_event;
		uint time;
		uint state;
		uint keyval;
		int length;
		char *string;
		ushort hardware_keycode;
		byte group;
		uint is_modifier;
	};
	
	// Core GTK functions
	void gtk_container_add(void*, void*);
	void gtk_init(int, char**);
	void gtk_main();
	void gtk_main_quit();
	void gtk_widget_show_all(gpointer);

	// GTK Widget functions
	gpointer gtk_window_new(int);
	void gtk_widget_add_events(gpointer, int);
	gpointer gtk_drawing_area_new();
	gpointer gtk_widget_get_window(gpointer);
	void gdk_drawable_get_size(gpointer, int*, int*);
	void gtk_window_set_title(gpointer, const char*);
	void gtk_window_set_default_size(gpointer, int, int);
	void gtk_widget_queue_draw_area(gpointer, int, int, int, int);
	
	// GTK Signal Functions
	void g_signal_connect_data(gpointer, const char*, gpointer, gpointer, gpointer, int);
	void g_timeout_add(uint, gpointer, gpointer);

	// Cairo Functions
	cairo_t gdk_cairo_create(gpointer);
	void cairo_arc(cairo_t, double, double, double, double, double);
	void cairo_clip(cairo_t);
	void cairo_destroy(cairo_t);
	void cairo_fill(cairo_t);
	void cairo_fill_preserve(cairo_t);
	Pattern cairo_get_source(cairo_t);
	cairo_surface_t cairo_get_target(cairo_t);
	int cairo_image_surface_get_width(cairo_surface_t);
	int cairo_image_surface_get_height(cairo_surface_t);
	void cairo_line_to(cairo_t, double, double);
	void cairo_move_to(cairo_t, double, double);
	void cairo_paint(cairo_t);
	void cairo_paint_with_alpha(cairo_t, double);
	Pattern cairo_pop_group(cairo_t);
	void cairo_pop_group_to_source(cairo_t);
	void cairo_push_group(cairo_t);
	void cairo_push_group_with_content(cairo_t, Content);
	void cairo_rectangle(cairo_t, double, double, double, double);
	void cairo_restore(cairo_t);
	void cairo_save(cairo_t);
	void cairo_select_font_face(cairo_t, const char*, int, int);
	void cairo_set_antialias(cairo_t, int);
	void cairo_set_dash(cairo_t, double*, int, int);
	void cairo_set_fill_rule(cairo_t, int);
	void cairo_set_font_size(cairo_t, double);
	void cairo_set_miter_limit(cairo_t, double);
	void cairo_set_source(cairo_t, Pattern);
	void cairo_set_source_rgb(cairo_t, double, double, double);
	void cairo_set_source_rgba(cairo_t, double, double, double, double);
	void cairo_set_line_cap(cairo_t, int);
	void cairo_set_line_join(cairo_t, int);
	void cairo_set_line_width(cairo_t, double);
	void cairo_set_operator(cairo_t, int);
	void cairo_set_tolerance(cairo_t, double);
	void cairo_show_text(cairo_t, const char *);
	void cairo_stroke(cairo_t);
	void cairo_stroke_preserve(cairo_t);
	void cairo_text_extents(cairo_t, const char *, TextExtents*);
}
