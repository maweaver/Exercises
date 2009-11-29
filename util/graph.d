module util.graph;

import std.algorithm;
import std.conv;
import std.stdio;

import util.dll;
import util.leftheap;

/++
 +  A subset of a graph, with a weight associated with it.  This may be the sum of the weight property on
 +  each vertex, or simply the size of the group.
+/
class WeightedGroup {
	this(LinkedList!(Vertex) members, int weight) {
		this.members = members;
		this.weight = weight;
	}

	this() {
		this.members = new LinkedList!(Vertex)();
		this.weight = 0;
	}

	LinkedList!(Vertex)  members;
	int                  weight;
}

/++
 +  An finite undirected graph.  All vertices are identified by an unsigned integer vertex number.  Both
 +  vertices and edges can have an arbitrary number of integer properties on them.  For efficiency, properties
 +  are indexed by unsigned integers.  Indexes are assigned at the graph level.
 +/
class Graph {

	protected:

	Vertex[]       _vertices;
	uint[string]   _vertexPropNames;
	uint[string]   _edgePropNames;
	bool[]         _adjacent;
	uint           _numEdges;
	uint           _numVertices;

	public:
	
	/++
	 +  Constructor
	 +/
	this(int initialCapacity = 100, 
		 string[] initialVertexProps = [ "visited", "cumDistance", "prev", "color", "subClique" ], 
		 string[] initialEdgeProps = [ "distance" ]) 
	{
		_numEdges = 0;
		_numVertices = 0;

		foreach(vertexProp; initialVertexProps) {
			_vertexPropNames[vertexProp] = _vertexPropNames.keys.length - 1;
		}
		
		foreach(edgeProp; initialEdgeProps) {
			_edgePropNames[edgeProp] = _edgePropNames.keys.length - 1;
		}

		realloc(initialCapacity);
	}

	void realloc(int numVerts) {
		auto origSize = _vertices.length;
		if(numVerts > origSize) {
			_vertices.length = numVerts;
			_adjacent.length = numVerts * numVerts;
		}
		_numVertices = numVerts;

		for(int i = origSize; i < numVertices; i++) {
			_vertices[i] = new Vertex(i);
			_vertices[i].props.length = _vertexPropNames.keys.length;
		}
	}

	/++
	 +  The number of vertices in the graph
	 +/
	uint numVertices() {
		return _numVertices;
	}
	
	/++
	 +  Creates a new vertex on the graph, without connecting it to any others.
	 +/
	uint createVertex(bool preserveEdgeProps = false) {
		auto v = new Vertex(numVertices);
		v.props.length = _vertexPropNames.keys.length;
		_vertices ~= v;
		_numVertices++;
		
		_adjacent.length = numVertices * numVertices;
		
		if(preserveEdgeProps) {
			// TODO: Copy over existing properties
		}
		
		return v.id;
	}
	
	/++
	 +  Creates a new edge connecting the given vertices
	 +/
	void createEdge(Vertex v1, Vertex v2) {
		if(!_adjacent[v1.id * numVertices + v2.id]) {
			_adjacent[v1.id * numVertices + v2.id] = true;
			_adjacent[v2.id * numVertices + v1.id] = true;
		
			v1.adjacent.pushTail(v2.id);
			v2.adjacent.pushTail(v1.id);
			_numEdges++;
		}
	}

	uint numEdges() {
		return _numEdges;
	}
	
	/++
	 +  Removes an edge between two vertices
	 +/
	void removeEdge(Vertex v1, Vertex v2) {
		_adjacent[v1.id * numVertices + v2.id] = false;
		_adjacent[v2.id * numVertices + v1.id] = false;
		
		v1.adjacent.remove(v2.id);
		v2.adjacent.remove(v1.id);

		_numEdges--;
	}
	
	/++
	 +  Gets a vertex by id
	 +/
	Vertex getVertex(uint id) {
		return _vertices[id];
	}
	
	/++
	 +  Returns the identifier for working with the given property on vertices
	 +/
	uint getVertexPropId(string propName) {
		if(propName in _vertexPropNames) {
			return _vertexPropNames[propName];
		} else {
			uint propId = _vertexPropNames.length;
			_vertexPropNames[propName] = propId;
			for(int i = 0; i < numVertices; i++) {
				auto v = _vertices[i];
				v.props.length = _vertexPropNames.keys.length;
			}
			return propId;
		}
	}
	
	/++
	 +  Returns the identifier for working with the given property on edges
	 +/
	uint getEdgePropId(string propName) {
		if(propName in _edgePropNames) {
			return _edgePropNames[propName];
		} else {
			uint propId = _edgePropNames.length;
			_edgePropNames[propName] = propId;
			
			for(int i = 0; i < numVertices; i++) {
				auto v = _vertices[i];
				foreach(v2, props; v.edgeProps) {
					props.length = _edgePropNames.keys.length;
				}
			}
			
			return propId;
		}
	}
	
	/++
	 +  Returns the array of properties for the edge between the two given vertices
	 +/
	int edgeProp(Vertex v1, Vertex v2, uint propId) {
		if(v1.id > v2.id) {
			auto tmp = v1;
			v1 = v2;
			v2 = tmp;
		}
		
		if(v2.id in v1.edgeProps) {
			return v1.edgeProps[v2.id][propId];
		} else {
			return int.init;
		}
	}
	
	void setEdgeProp(Vertex v1, Vertex v2, uint propId, int value) {
		if(v1.id > v2.id) {
			auto tmp = v1;
			v1 = v2;
			v2 = tmp;
		}
		
		if(!(v2.id in v1.edgeProps)) {
			v1.edgeProps[v2.id] = new int[_edgePropNames.keys.length];
		}		
		
		v1.edgeProps[v2.id][propId] = value;
	}

	/++
	 +  Calls \c fn for each possible pairing of vertexes.  \c fn will be called a total of \f$ \binom{2}{n} \f$
	 +  times.
	 +/
	void combine(void delegate(Vertex, Vertex) fn) {
		for(int i = 0; i < numVertices; i++) {
			auto v = _vertices[i];
			foreach(v2; _vertices[i + 1 .. numVertices]) {
				fn(v, v2);
			}
		}
	}
	
	/++
	 +  Finds the shortest path between two nodes using Dijkstra's algorithm.  If \a to is null, finds the 
	 +  shortest path from the start node to every other node.
	 +
	 +  If the \c distance property is set on an edge, that is used as the distance between its vertices.  If it
	 +  is unset or 0, a distance of 1 is assumed.
	 +
	 +  This procedures sets as its result the property \c prev on the target node, if set, or all nodes, if the
	 +  target node is not set.  The \c prev property is the id of the previous node on a path from the target
	 +  to the start.  This previous node in turn also has this property set, forming a chain.
	 +/
	void shortestPath(uint startId, uint targetId = uint.max, bool useDistance = true) {
		auto start = getVertex(startId);
		auto target = targetId == uint.max ? null : getVertex(targetId);
		
		auto visited = getVertexPropId("visited");
		auto cumDist = getVertexPropId("cumDistance");
		auto prev = getVertexPropId("prev");
		auto distance = useDistance ? getEdgePropId("distance") : 0;
		
		for(int i = 0; i < numVertices; i++) {
			auto v = _vertices[i];
			v.props[visited] = 0;
			v.props[cumDist] = int.max;
			v.props[prev] = -1;
		}
		
		start.props[cumDist] = 0;
		start.props[visited] = 1;
		Vertex v = start;
		auto eligibles = new LeftHeap!(int)();
		
		while(true) {

			foreach(v2Id; v.adjacent) {
				auto v2 = getVertex(v2Id);
				auto vDist = v.props[cumDist];
				auto v2Dist = v2.props[cumDist];
				
				
				int eDist = 1;
				
				if(useDistance) {
					eDist = edgeProp(v, v2, distance);
				}
				
				if(v2Dist > vDist + eDist) {
					v2.props[cumDist] = vDist + eDist;
					v2.props[prev] = v.id;
					
					eligibles.remove(v2.id);
					
					if(!v2.props[visited]) {
						eligibles.insert(vDist + eDist, v2.id);
					}
				}
				
				if(v2Id == targetId) {
					break;
				}
			}
			
			v.props[visited] = 1;
			eligibles.remove(v.id);

			if(eligibles.isEmpty()) {
				break;
			}
			
			v = getVertex(eligibles.poll());			
		} 
	}
	
	/++
	 +  Color the graphy heuristically.  This produces a valid coloring quickly, but it is probably not the 
	 +  minimal colering.  Colors are set in the color property of each vertex.
	 +
	 +  This is potentially a O(n^3) operation (for a clique).
	 +/
	void greedyColor(bool delegate(Vertex, Vertex) sortComp) {
		auto sorted = new Vertex[numVertices];
		for(int i = 0; i < sorted.length; i++) { 
			sorted[i] = _vertices[i]; 
		}

		sort!(sortComp)(sorted);

		auto color = getVertexPropId("color");
		foreach(v; sorted) {
			v.props[color] = -1;
		}
		
		foreach(v1; sorted) {
			auto curColor = 0;
			auto valid = true;
			do {
				valid = true;
				foreach(v2; v1.adjacent) {
					if(getVertex(v2).props[color] == curColor) {
						curColor++;
						valid = false;
						break;
					}
				}
			} while(!valid)
			v1.props[color] = curColor;
		}
	}
	
	/++
	 +  Complement this graph.  Connect all points which are currently non-adjacent, and remove all existing
	 +  connections.  This necessarily loses any properties on the edges, though the vertex properties remain.
	 +  Calling complement() twice should result in the original graph.
	 +/
	void complement() {
		_numEdges = 0;
		for(int i = 0; i < numVertices; i++) {
			auto v1 = getVertex(i);
			v1.adjacent.clear();
			
			for(int j = 0; j < numVertices; j++) {
				if(i != j) {
					_adjacent[i * numVertices + j] = !_adjacent[i * numVertices + j];
				
					if(_adjacent[i * numVertices + j]) {
						v1.adjacent ~= j;
						_numEdges++;
					}
				}
			}
		}
		_numEdges /= 2;
	}

	void clearEdges() {
		for(int i = 0; i < _adjacent.length; i++) {
			_adjacent[i] = false;
		}

		for(int i = 0; i < numVertices; i++) {
			auto v = _vertices[i];
			v.adjacent.clear();
		}
	}
	
	/++
	 +  Finds the maximum clique of the graph, either by size or by weight.  Uses the algorithm
	 +  described in "A new exact algorithm for the maximum-weight clique problem based on a
	 +  heuristic vertex-coloring and a backtrack search," by Deniss Kumlander 
	 +  (http://www.math.kth.se/4ecm/abstracts/6.17.pdf)
	 +/
	WeightedGroup maxClique(bool weighted = false, Vertex[] subgraph = []) {
		if(subgraph.length == 0) {
			subgraph = _vertices[0..numVertices];
		}

		ulong numExamined = 0;
		auto color = getVertexPropId("color");
		auto weight = weighted ? getVertexPropId("weight") : 0;
		auto subClique = getVertexPropId("subClique");
		
		bool sortComp(Vertex a, Vertex b) {
			return a.props[color] < b.props[color] || 
				(weighted && 
				 a.props[color] == b.props[color] && 
				 a.props[weight] < b.props[weight]);
		}

		auto sorted = subgraph.dup;
		sort!(sortComp)(sorted);

		auto bestClique = new WeightedGroup();

		void processDepth(WeightedGroup clique, Vertex[] graph, int graphSize, int degree, int depth) {
			auto graphStart = 0;
			while(graphSize > 0) {
				if(clique.weight + degree > bestClique.weight) {
					auto v = graph[graphStart];
					graphStart++;
					graphSize--;

					if(graphSize == 0 || v.props[color] != graph[graphStart].props[color]) {
						degree -= (weighted ? v.props[weight] : 1);
					}

					foreach(v2; clique.members) {
						if(!_adjacent[v.id * numVertices + v2.id]) {
							continue;
						}
					}
						
					if(clique.weight + v.props[subClique] > bestClique.weight) {
						auto nextDegree = 0;
						auto lastColor = -1;
						auto lastWeight = 0;

						auto nextGraph = new Vertex[graphSize];
						auto nextGraphSize = 0;

						for(int i = graphStart; i < graphStart + graphSize; i++) {
							auto v2 = graph[i];
							if(_adjacent[v.id * numVertices + v2.id]) {
								nextGraph[nextGraphSize++] = v2;
								if(v2.props[color] != lastColor) {
									nextDegree += lastWeight;
								}
								lastColor = v2.props[color];
								lastWeight = weighted ? v2.props[weight] : 1;
							}
						}

						nextDegree += lastWeight;
						clique.members.pushTail(v);
						clique.weight += weighted ? v.props[weight] : 1;

						processDepth(clique, nextGraph, nextGraphSize, nextDegree, depth + 1);

						clique.members.popTail();
						clique.weight -= weighted ? v.props[weight] : 1;
					} else {
						break;
					}
				} else {
					break;
				}
			}
			if(clique.weight > bestClique.weight) {
				bestClique.members = clique.members.dup;
				bestClique.weight = clique.weight;
			}
		}

		for(uint n = sorted.length - 1; n != uint.max; n--) {
			// Create an initial depth for the given n by starting with a clique whose members are n,
			// and selecting all vertices with index > n which are connected to n.
			auto degree = 0;
			auto lastColor = -1;
			auto lastWeight = 0;
			auto graph = new Vertex[sorted.length];
			auto graphSize = 0;
			for(uint i = n + 1; i < sorted.length; i++) {
				auto v = sorted[i];
				if(_adjacent[v.id * numVertices + sorted[n].id]) {
					graph[graphSize++] = v;
					if(lastColor != -1 && v.props[color] != lastColor) {
						degree += lastWeight;
					}
					lastColor = v.props[color];
					lastWeight = weighted ? v.props[weight] : 1;
				}
			}
			degree += lastWeight;
			processDepth(new WeightedGroup(new LinkedList!(Vertex)([ sorted[n] ]), weighted ? sorted[n].props[weight] : 1), graph, graphSize, degree, 1);
			sorted[n].props[subClique] = bestClique.weight;
		}
		return bestClique;
	}
	
	WeightedGroup bruteMaxClique(bool weighted = false) {
		auto weight = weighted ? getVertexPropId("weight") : 0;
		auto ret = new WeightedGroup();
		
		void bruteMaxCliqueStep(WeightedGroup cur, Vertex[] others) {
			bool foundOne = false;
			foreach(idx, v; others) {
				bool valid = true;
				foreach(v2; cur.members) {
					if(!_adjacent[v.id * numVertices + v2.id]) {
						valid = false;
						break;
					}
				}
				if(valid) {
					foundOne = true;
					bruteMaxCliqueStep(new WeightedGroup(cur.members.dup ~ v, cur.weight + (weighted ? v.props[weight] : 1)), 
									   others[0..idx] ~ others[idx+1..$]);
				}
			}
			if(!foundOne) {
				if(cur.weight > ret.weight) {
					ret.members = cur.members.dup;
					ret.weight = cur.weight;
				}
			}
		}

		for(int i = 0; i < numVertices; i++) {
			auto v = _vertices[i];
			bruteMaxCliqueStep(new WeightedGroup(new LinkedList!(Vertex)([ v ]), weighted ? v.props[weight] : 1), _vertices[0..i] ~ _vertices[i + 1..numVertices]);
		}

		return ret;
	}

	/**
	 * Create a new graph by inducing a subset on this graph.
	 */
	Graph subset(Vertex[] included) {
		auto g = new Graph(included.length);
		foreach(idx, v; included) {
			/* Copy all properties */
			g.getVertex(idx).props = v.props.dup;

			/* Copy edges */
			foreach(adj; v.adjacent) {
				int adjId = -1;
				foreach(idx2, v2; included) {
					if(v2.id == adj) {
						adjId = idx2;
						break;
					}
				}

				if(adjId != -1) {
					g.createEdge(g.getVertex(idx), g.getVertex(adjId));
				}
			}
		}

		return g;
	}

	/++
	 +  Creates a .dot representation of this graph convertable to graphics format using graphviz
	 +/
	void dot(File f, string delegate(Vertex) vertexFn, string delegate(Vertex, Vertex) edgeFn) {
		f.writeln("graph G {");
		f.writeln("\tgraph [overlap=scale, outputorder=edgesfirst];");

		for(int i = 0; i < numVertices; i++) {
			auto v = _vertices[i];
			foreach(v2Id; v.adjacent) {
				auto v2 = getVertex(v2Id);
				f.writefln("\t\"%d\" [%s];", v.id, vertexFn(v));
				f.writefln("\t\"%d\" -- \"%d\" [%s];", v.id, v2.id, edgeFn(v, v2));
			}
		}
		
		f.writeln("}");
	}
	
	protected:
	
	uint edgePropOffset(uint v1, uint v2, uint propId) {
		if(v1 > v2) {
			auto tmp = v1;
			v1 = v2;
			v2 = tmp;
		}
		
		return propId * numVertices * numVertices + v1 * numVertices + v2;
	}
}

/++
 +  A vertex on the graph.
 +/
class Vertex {
	protected:

	uint    _id;
		
	public:
		
	/++
	 +  Properties associated with this vertex
	 +/
	int[] props;
	
	int[][int] edgeProps;
	
	/++
	 +  Adjacent vertices
	 +/
	LinkedList!(uint) adjacent;
	
	/++
	 +  Constructor
	 +/
	this(uint id) {
		_id = id;
		adjacent = new LinkedList!(uint)();
	}
		
	/++
	 +  Vertex number
	 +/
	uint id() {
		return _id;
	}
}
