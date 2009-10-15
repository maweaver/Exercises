import std.conv;
import std.stdio;
import std.string;

/++
 +  An generic undirected graph
 +/
class Graph(T) {

	public:
	
	/++
	 +  A vertex on the graph.
	 +/
	static class Vertex {
		protected:
		
		T      _data;
		Edge[] _edges;
		bool   _visited;
		uint   _totalDistance;
		Vertex _prev;
		
		public:
		
		/++
		 +  Constructor
		 +/
		this(T data, Edge[] edges = []) {
			_data = data;
			_edges = edges;
		}
		
		/++
		 +  The data stored at this vertex
		 +/
		T data() {
			return _data;
		}
		
		/++
		 +  The edges connecting this vertex to other vertices
		 +/
		Edge[] edges() {
			return _edges;
		}
		
		/++
		 +  Creates a two-way connection between a pair of vertices
		 +/
		void connectTo(Vertex v, uint distance) {
			auto edge = new Edge(this, v, distance);
			_edges ~= edge;
			v._edges ~= edge;
		}

		/++
		 +  Whether this vertex has been visited.  Allows implementation of visiting algorithms while avoiding
		 +  cycles.
		 +/
		bool visited() {
			return _visited;
		}
		
		bool visited(bool value) {
			return _visited = value;
		}
		
		/++
		 +  The total distance from this node to some other, including the distance of other vertexes in between.
		 +/
		uint totalDistance() {
			return _totalDistance;
		}
		
		uint totalDistance(uint value) {
			return _totalDistance = value;
		}
		
		/++
		 +  The previous vertex on a path to a destination
		 +/
		Vertex prev() {
			return _prev;
		}
		
		Vertex prev(Vertex value) {
			return _prev = value;
		}
	}
	
	/++
	 +  An edge, connecting two vertices
	 +/
	static class Edge {
		protected:
		
		Vertex _v1;
		Vertex _v2;
		uint   _distance;
		bool   _visited;
		
		public:
		
		/++
		 +  Constructor
		 +/
		 this(Vertex v1, Vertex v2, uint distance) {
			 _v1 = v1;
			 _v2 = v2;
			 _distance = distance;
		 }
		 
		 /++
		  +  One side of the connection
			+/
		 Vertex v1() {
			 return _v1;
		 }
		 
		 /++
		  +  One side of the connection
			+/
		 Vertex v2() {
			 return _v2;
		 }
		 
		 /++
		  +  Distance from v1 to v2
			+/
		 uint distance() {
				return _distance;
		 }
		 
		 /++
		  +  Whether this edge has been visited
			+/
			bool visited() {
				return _visited;
			}
			
			bool visited(bool value) {
				return _visited = value;
			}
	}
	
	protected:

	Vertex[T] _vertices;
	
	/++
	 +  Creates a new vertex on the graph, without connecting it to any others.
	 +/
	Vertex createVertex(T data) {
		auto v = new Vertex(data);
		_vertices[data] = v;
		return v;
	}
	
	/++
	 +  Marks all vertexes as unvisited
	 +/
	void unvisitAll() {
		foreach(d, v; _vertices) {
			v.visited = false;
			v.totalDistance = uint.max;
			v.prev = null;
			foreach(e; v.edges) {
				e.visited = false;
			}
		}
	}
	
	public:
	
	/++
	 +  Finds a vertex based on its data value
	 +/
	Vertex findVertex(T data) {
		return _vertices[data];
	}
	
	/++
	 +  Calls fn for each possible pairing of vertexes (Careful, that means its an n! operation).  If fn returns
	 +  uint.max, nothing happens.  Otherwise, an edge is created with its distance set to the return value.
	 +/
	void webify(uint function(Vertex, Vertex) fn) {
		unvisitAll();
		
		Vertex[] unvisited;
		foreach(d, v; _vertices) {
			unvisited ~= v;
		}
		foreach(idx, v; unvisited) {
			foreach(v2; unvisited[idx+1..$]) {
				auto distance = fn(v, v2);
				if(distance != uint.max) {
					v.connectTo(v2, distance);
				}
			}
		}
	}
	
	/++
	 +  Finds the shortest path between two nodes using Dijkstra's algorithm.  If to is null, finds the shortest
	 +  path from the start node to every other node.
	 +/
	void shortestPath(T fromData, T toData = null) {
		unvisitAll();
		
		auto from = findVertex(fromData);
		auto to = findVertex(toData);
		
		from.totalDistance = 0;
		from.visited = true;
		Vertex v = from;
		bool[Vertex] eligibles;
		while(true) {

			foreach(e; v.edges) {
				Vertex v2 = e.v1 == v ? e.v2 : e.v1;
				if(v2.totalDistance > v.totalDistance + e.distance) {
					v2.totalDistance = v.totalDistance + e.distance;
					v2.prev = v;
					eligibles[v2] = !v2.visited;
				}
				if(v2 == to) {
					break;
				}
			}
			
			v.visited = true;
			eligibles[v] = false;
			
			v = null;
			foreach(next, eligible; eligibles) {
				if(eligible && (!v || next.totalDistance < v.totalDistance)) {
					v = next;
				}
			}
			
			if(!v) {
				break;
			}
		} 
	}
	
	string toString() {
		unvisitAll();
		
		string ret = "graph G {\n";
		
		foreach(d, v; _vertices) {
			foreach(e; v.edges) {
				if(!e.visited) {
					e.visited = true;
					ret ~= "\"" ~ to!(string)(e.v1.data) ~ "\" -- \"" ~ to!(string)(e.v2.data) ~ "\" [label=" ~ to!(string)(e.distance) ~ "];\n";
				}
			}
		}
		ret ~= "}\n";
		
		return ret;
	}
}

uint areWordsConnected(Graph!(string).Vertex v1, Graph!(string).Vertex v2) {
	int numDiffs = 0;
	for(int i = 0; i < v1.data.length; i++) {
		if(v1.data[i] != v2.data[i]) {
			numDiffs++;
		}
		if(numDiffs > 1) {
			return uint.max;
		}
	}
	
	return 1;
}

Graph!(string) createDictGraph(int len) {
	auto g = new Graph!(string)();
	auto dict = File("/usr/share/dict/words", "r");
	char[] word;
	
	while(dict.readln(word)) {
		word.length = word.length - 1;
		if(word.length == len) {
			auto lword = tr(to!(string)(word), uppercase, lowercase);
			bool valid = true;
			foreach(ch; lword) {
				if(!inPattern(ch, lowercase)) {
					valid = false;
					break;
				}
			}
			
			if(valid) {
				g.createVertex(lword);
			}
		}
	}
	
	g.webify(&areWordsConnected);
	
	return g;
}

void main() {
	
	auto word1 = "white";
	auto word2 = "black";
	
	auto g = createDictGraph(word1.length);
	
	g.shortestPath(word2, word1);
	
	auto curVertex = g.findVertex(word1);
	while(curVertex) {
		writefln("%s", curVertex.data);
		curVertex = curVertex.prev;
	}
}
