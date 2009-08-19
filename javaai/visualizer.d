import std.math;
import std.stdio;
import std.string;

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
 + A two-dimensional point.
 +/
struct Point {
	double x;  /// X coordinate of the point
	double y;  /// Y coordinate of the point
}

/++
 + A size
 +/
struct Size {
	double width;   /// Width of the size
	double height;  /// Height of the size
}

/++
 + The style used to draw the ends of lines
 +/
enum LineCap {
	Butt,   /// No extra ending to the line
	Round,  /// Rounded cap to the line
	Square  /// Squared cap to the line
}

/++
 + The style used to join lines
 +/
enum LineJoin {
	Miter,  /// Edges are extended to form sharp corners
	Round,  /// Edges are rounded
	Bevel   /// Edges are chopped
}

/++
 + Slant of the font
 +/
enum FontSlant {
	Normal,
	Italic,
	Oblique
}

/++
 + Weight of the font
 +/
enum FontWeight {
	Normal,
	Bold
}

/++
 + All drawing operations are performed via the canvas.  The canvas uses logical coordinates to simplify
 + scaling the image.  By default the logical size is 100x100, with (0, 0) being the center of the screen.  
 + So the far left of the screen is at x = -50, and the right side is at x = +50.
 +/
class Canvas {
	private:
	
	cairo_t _cr;
	int _imageWidth;
	int _imageHeight;
	
	public:
	
	/++
	 + Constructor
	 +/
	this(cairo_t cr, int imageWidth, int imageHeight) {
		_cr = cr;
		
		logicalWidth = 100;
		logicalHeight = 100;
		_imageWidth = imageWidth;
		_imageHeight = imageHeight;
	}
	
	/++
	 + The logical width of the image.
	 +/
	int logicalWidth;
	
	/++
	 + The logical height of the image
	 +/
	int logicalHeight;
	
	/++
	 + The physical width of the image
	 +/
	int imageWidth() { 
		return _imageWidth; 
	}
	
	/++
	 + The physical height of the image
	 +/
	int imageHeight() { return _imageHeight; }
	
	/++
	 + Converts a point from its logical coordinates to a physical point on the screen.
	 +/
	Point logicalToImage(Point p) {
		auto scale = fmin(cast(real) imageWidth / cast(real) logicalWidth,
			cast(real) imageHeight / cast(real) logicalHeight);
		
		return Point(p.x * scale + cast(real) logicalWidth * scale / 2.0, 
			           p.y * scale + cast(real) logicalHeight * scale / 2.0);
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
	
	/++
	 + Fills the canvas with a solid color.
	 +
	 + Params:
	 +   color = Color to fill with
	 +/
	void fill(Color color) {
		drawRectangle(Point(- cast(real) logicalWidth / 2.0, - cast(real) logicalHeight / 2.0),
			Size(logicalWidth, logicalHeight),
			color, color);
	}
}

/++
 + A callback function which does the drawing.
 +/
typedef void function(Canvas) DrawFunction;

extern(C) {
	void *visualization_draw_handler(gpointer w, gpointer e, gpointer data) {
		int width;
		int height;
		gdk_drawable_get_size(gtk_widget_get_window(w), &width, &height);
		
		auto context = gdk_cairo_create(gtk_widget_get_window(w));
		cairo_rectangle(context, 0, 0, width, height);
		cairo_clip(context);
		
		auto surface = cairo_get_target(context);
	
		auto drawFn = *(cast(DrawFunction*) data);
		drawFn(new Canvas(context, width, height));
	
		cairo_destroy(context);
		return null;
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
void createDrawing(string title, DrawFunction fn, Size size = Size(200, 200)) {
	gtk_init(0, null);
	
	auto window = gtk_window_new(0);
	auto da = gtk_drawing_area_new();
	
	g_signal_connect_data(da, toStringz("expose-event"), cast(gpointer) &visualization_draw_handler, cast(gpointer) &fn, null, 0);
	g_signal_connect_data(window, toStringz("destroy"), cast(gpointer) &gtk_main_quit, null, null, 0);
	gtk_container_add(window, da);
	
	gtk_window_set_title(window, toStringz(title));
	gtk_window_set_default_size(window, cast(int) size.width, cast(int) size.height);
	
	gtk_widget_show_all(window);
	gtk_main();
}

extern(C) {
	// Basic types
	typedef void *gpointer;
	typedef void *cairo_t;
	typedef void *cairo_surface_t;
	
	// Core GTK functions
	void gtk_container_add(void*, void*);
	void gtk_init(int, char**);
	void gtk_main();
	void gtk_main_quit();
	void gtk_widget_show_all(gpointer);

	// GTK Widget functions
	gpointer gtk_window_new(int);
	gpointer gtk_drawing_area_new();
	gpointer gtk_widget_get_window(gpointer);
	void gdk_drawable_get_size(gpointer, int*, int*);
	void gtk_window_set_title(gpointer, const char*);
	void gtk_window_set_default_size(gpointer, int, int);

	// GTK Signal Functions
	void g_signal_connect_data(gpointer, const char*, gpointer, gpointer, gpointer, int);

	// Cairo Functions
	cairo_t gdk_cairo_create(gpointer);
	void cairo_arc(cairo_t, double, double, double, double, double);
	void cairo_clip(cairo_t);
	void cairo_destroy(cairo_t);
	void cairo_fill(cairo_t);
	cairo_surface_t cairo_get_target(cairo_t);
	int cairo_image_surface_get_width(cairo_surface_t);
	int cairo_image_surface_get_height(cairo_surface_t);
	void cairo_line_to(cairo_t, double, double);
	void cairo_move_to(cairo_t, double, double);
	void cairo_rectangle(cairo_t, double, double, double, double);
	void cairo_select_font_face(cairo_t, const char*, int, int);
	void cairo_set_dash(cairo_t, double*, int, int);
	void cairo_set_font_size(cairo_t, double);
	void cairo_set_source_rgba(cairo_t, double, double, double, double);
	void cairo_set_line_cap(cairo_t, int);
	void cairo_set_line_join(cairo_t, int);
	void cairo_set_line_width(cairo_t, double);
	void cairo_show_text(cairo_t, const char *);
	void cairo_stroke(cairo_t);
	void cairo_stroke_preserve(cairo_t);
}

////////////////////////////////////////////////////////////////////////////////
//
// Sample
//
////////////////////////////////////////////////////////////////////////////////

void draw(Canvas c) {
	c.fill(Color(1.0, 0.5, 0.3));
	c.drawCircle(Point(0, 0), 33, 
		Color(0.0, 0.0, 0.0, 1.0), 
		Color(0.0, 1.0, 0.0, 0.7), 
		2, [ 1.0, 3.0 ]);
	c.drawLine(Point(-25, -25), Point(25, 25), Color(1.0, 0.0, 0.0, 0.5), 5.0);
	c.drawLine(Point(25, -25), Point(-25, 25), Color(0.0, 0.0, 1.0, 0.5), 5.0);
	c.drawCircle(Point(-40, -40), Point(40, 40),
		Color(0.0, 0.0, 0.0, 0.0),
		Color(0.0, 0.0, 0.0, 0.2));
	c.drawRectangle(Point(-45, -45), Size(90, 10),
		Color(0.0, 0.0, 0.0, 1.0),
		Color(0.0, 0.0, 0.3, 1.0), 5);
	c.drawRectangle(Point(-45, 35), Point(45, 45),
		Color(0.0, 0.0, 0.0, 1.0),
		Color(0.0, 0.0, 0.3, 1.0), 5);
	c.drawText("Hello, World", Point(-45, -35), 10, "Sans", FontSlant.Italic, FontWeight.Bold, Color(1.0, 1.0, 1.0, 1.0));
}

void main() {
//	createDrawing("Maze", &draw, Size(500, 500));
}
