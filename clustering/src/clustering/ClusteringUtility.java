package clustering;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.collections15.Factory;
import org.apache.commons.collections15.Transformer;

import cern.colt.matrix.impl.SparseDoubleMatrix2D;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;
import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph;

import edu.uci.ics.jung.algorithms.flows.EdmondsKarpMaxFlow;
import edu.uci.ics.jung.graph.DirectedGraph;
import edu.uci.ics.jung.graph.DirectedSparseGraph;

public class ClusteringUtility {
	
	public static double getWeight(Edge e) {
		try {
			return (Double) e.getProperty("weight");
		} catch (NullPointerException n) {
			return 0;
		}
	}

	public static double sumWeights(Map<Vertex, Map<Vertex, Double>> adjacency, Vertex v, Set<Vertex> cluster1) {
		double sum = 0;
		for (Vertex u : cluster1)
			if (adjacency.get(v) != null && adjacency.get(v).get(u) != null)
				sum += adjacency.get(v).get(u);
		return sum;
	}

	public static double sumWeights(SparseDoubleMatrix2D adjacency, Vertex v, Set<Vertex> cluster1) {
		double sum = 0;
		for (Vertex u : cluster1)
			sum += adjacency.get((Integer)v.getId(),(Integer)u.getId());
		return sum;
	}
	
	public static DirectedGraph<Vertex, Edge> convertToDirectedGraph(Graph g) {
		DirectedGraph<Vertex, Edge> graph = new DirectedSparseGraph<Vertex, Edge>();
		for (Vertex v : g.getVertices())
			graph.addVertex(v);
		for (Edge e : g.getEdges())
			graph.addEdge(e, e.getOutVertex(), e.getInVertex());
		return graph;
	}
	
	/**
	 * Calculates the maximum flow problem for graph g with given vertices.
	 * @param g
	 * @param source
	 * @param destination
	 * @return An array with the first element containing the maximum flow and the second a Set<Edge> collection with the minimum cut edges
	 */
	public static Object[] getMaxFlow(Graph g, Vertex source, Vertex destination, final AdjacencyInterface adj) {
		Transformer<Edge, Number> transformer = new Transformer<Edge, Number>() {

			@Override
			public Number transform(Edge arg0) {
				return adj.getAdjacency(arg0.getOutVertex(), arg0.getInVertex()) * 1000;
			}
			
		};
		Factory<Edge> factory = new Factory<Edge>() {

			@Override
			public Edge create() {
				return new MyEdge();
			}
			
		};
		// Fix the directedgraph thing!
		EdmondsKarpMaxFlow<Vertex, Edge> maxflow = new EdmondsKarpMaxFlow<Vertex, Edge>(ClusteringUtility.convertToDirectedGraph(g), source, destination, transformer, new HashMap<Edge, Number>(), factory);
		
		maxflow.evaluate();
		
		Object[] result = new Object[2];
		result[0] = maxflow.getMaxFlow() / 1000.0;
		result[1] = maxflow.getMinCutEdges();
		
		return result;
	}
	
	public static Graph sequentialGusfieldAlgorithm(Graph g) {
		return sequentialGusfieldAlgorithm(g, null);
	}

	public static Graph sequentialGusfieldAlgorithm(Graph g, AdjacencyInterface adj) {
		// TODO Auto-generated method stub
		Graph t = new TinkerGraph();
		// A map containing for each vertex the corresponding index where it can be found in the array Vertex (see later)
		Map<Vertex, Integer> vertexMap = new HashMap<Vertex, Integer>();
		int i = 0;
		for (Vertex v : g.getVertices()) {
			vertexMap.put(v, i++);
			t.addVertex(v.getId());
		}
		Vertex[] vertex = new Vertex[i];
		for (Entry<Vertex, Integer> entry : vertexMap.entrySet())
			vertex[entry.getValue()] = entry.getKey();
		// Default for int [] is value 0 => good!
		int n = vertex.length;
		int[] tree = new int[n];
		
		if (adj == null)
			adj = new AdjacencyLocal(g);
		
		
		double[] flow = new double[n];
		Map<Edge, Number> flowMap;
		for (i = 1; i < n; i++) {
			Object[] result = getMaxFlow(g, vertex[i], vertex[tree[i]], adj);
			flow[i] = (Double)result[0];
			for (Edge e : (Set<Edge>) result[1])
				adj.setAdjacency(e.getInVertex(), e.getOutVertex(), 0);
			Set<Vertex> cluster1 = calculateCluster(g, vertex[i], adj, new HashSet<Vertex>());
			for (int j = 1; j < n; j++) {
				if (j == i || j == tree[i])
					continue;
				// If the vertex and the parent are currently not in the same cluster (actually components divided by the cut)
				// then change the parent to point to the source of the sink of this iteration
				if (cluster1.contains(vertex[j]) && !cluster1.contains(vertex[tree[j]]))
					// source
					tree[j] = vertexMap.get(vertex[i]);
				else if (cluster1.contains(vertex[tree[j]]) && !cluster1.contains(vertex[j]))
					// sink
					tree[j] = vertexMap.get(vertex[tree[i]]);
			}
			for (Edge e : (Set<Edge>) result[1])
				adj.setAdjacency(e.getInVertex(), e.getOutVertex(), (Double)e.getProperty("weight"));
		}
		// Generate the graph
		for (i=0; i < n; i++) {
			if (flow[i] != 0)
				t.addEdge(null, vertex[i], vertex[tree[i]], "similarity").setProperty("weight", flow[i]);
		}
		return t;
	}
	
	public static AdjacencyInterface createAdjacencyInterface(Graph g) {
		return new AdjacencyLocal(g);
	}
	
	public static Set<Vertex> calculateCluster(Graph g, Vertex vertex, AdjacencyInterface adj, Set<Vertex> cluster) {
		cluster.add(vertex);
		for (Edge e : vertex.getInEdges())
			if (!cluster.contains(e.getOutVertex()) && adj.getAdjacency(e.getInVertex(), e.getOutVertex()) > 0) {
				calculateCluster(g, e.getOutVertex(), adj, cluster);
			}
		for (Edge e : vertex.getOutEdges())
			if (!cluster.contains(e.getInVertex()) && adj.getAdjacency(e.getInVertex(), e.getOutVertex()) > 0) {
				calculateCluster(g, e.getInVertex(), adj, cluster);
			}
		return cluster;
	}
	
	public static Set<Set<Vertex>> calculateComponents(Graph t) {
		Set<Set<Vertex>> set = new HashSet<Set<Vertex>>();
		List<Vertex> list = new ArrayList<Vertex>();
		for (Vertex v : t.getVertices()) {
			list.add(v);
		}
		while (list.size() > 0) {
			Set<Vertex> cluster = findAllConnectedVertices(t, list.get(0), new HashSet<Vertex>());
			for (Vertex v : cluster)
				list.remove(v);
			set.add(cluster);
		}
		return set;
	}

	public static Set<Vertex> findAllConnectedVertices(Graph g, Vertex vertex, Set<Vertex> cluster) {
		cluster.add(vertex);
		for (Edge e : vertex.getInEdges())
			if (!cluster.contains(e.getOutVertex()) && ClusteringUtility.getWeight(e) > 0) {
				findAllConnectedVertices(g, e.getOutVertex(), cluster);
			}
		for (Edge e : vertex.getOutEdges())
			if (!cluster.contains(e.getInVertex()) && ClusteringUtility.getWeight(e) > 0) {
				findAllConnectedVertices(g, e.getInVertex(), cluster);
			}
		return cluster;
	}

}

class AdjacencyLocal implements AdjacencyInterface {
	
	Map<Vertex, Map<Vertex, Double>> adj;
	
	public AdjacencyLocal(Graph g) {
		adj = new HashMap<Vertex, Map<Vertex, Double>>();
		for (Edge e : g.getEdges()) {
			if (e.getProperty("weight") == null)
				continue;
			this.setAdjacency(e.getOutVertex(), e.getInVertex(), (Double) e.getProperty("weight"));
		}
	}

	@Override
	public double getAdjacency(Vertex v, Vertex u) {
		try {
			return adj.get(v).get(u);
		} catch (NullPointerException n) {
			return 0;
		}
	}

	@Override
	public void setAdjacency(Vertex v, Vertex u, double weight) {
		if (!adj.containsKey(v))
			adj.put(v, new HashMap<Vertex, Double>());
		adj.get(v).put(u, weight);
		if (!adj.containsKey(u))
			adj.put(u, new HashMap<Vertex, Double>());
		adj.get(u).put(v, weight);
	}

	@Override
	public void increaseAdjacency(Vertex v, Vertex u, double weight) {
		// TODO Auto-generated method stub
		setAdjacency(v, u, weight + getAdjacency(v, u));
	}
	
}

class Couple<E> {
	
	E e;
	E v;
	
	Couple(E e, E v) {
		this.e = e;
		this.v = v;
	}
	
	void set(E e, E v) {
		this.e = e;
		this.v = v;
	}
	
	E getSource() {
		return e;
	}
	
	E getSink() {
		return v;
	}
	
	@Override
	public boolean equals(Object o) {
		if (o == this)
			return true;
		if (!(o instanceof Couple))
			return false;
		if (((Couple)o).getSink() == e && ((Couple)o).getSource() == v)
			return true;
		if (((Couple)o).getSink() == v && ((Couple)o).getSource() == e)
			return true;
		return false;
	}
}
