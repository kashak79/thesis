package clustering;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;
import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph;

public class DynMinCutClustering {
	
	Graph graph = null;
	ClusteringDataInterface clustering;
	int n;
	
	public DynMinCutClustering(ClusteringDataInterface clustering) {
		this.clustering = clustering;
		// TODO find quick way to find number of vertices in graph
		n = 0;
	}
	
	public void case3(Vertex i, Vertex j, double alpha) {
		Cluster<Vertex> cluster1 = getCluster(i);
		Cluster<Vertex> cluster2 = getCluster(j);
		Graph g = contractMattie(null, cluster1, cluster2);
		
		Vertex t = graph.addVertex(null);
		
		// Connect t to v, for all v in cluster1 or cluster2 with edge of weight alpha
		for (Vertex v : cluster1)
			this.addEdgeWithWeight(g, t, v, alpha);
		for (Vertex v : cluster2)
			this.addEdgeWithWeight(g, t, v, alpha);
		this.addEdgeWithWeight(g, t, null, alpha * (n - cluster1.size() - cluster2.size()));

		// TODO calculate the minimum-cut tree of graph g
		sequentialGusfieldAlgorithm(g);
	}
	
	private void sequentialGusfieldAlgorithm(Graph g) {
		// TODO Auto-generated method stub
		Graph t = new TinkerGraph();
		Map<Number, Integer> vertexMap = new HashMap<Number, Integer>();
		int i = 0;
		List<Vertex> vertex = new ArrayList<Vertex>();
		for (Vertex v : g.getVertices()) {
			vertexMap.put((Number)v.getId(), i);
			vertex.add(i++, v);
			t.addVertex(v);
		}
		Vertex[] vtx = vertex.toArray(new Vertex[0]);
		int[] tree = new int[i];
		i = 0;
		for (Vertex v : tree)
			v = vertex[0];
		
		double[] flow = new double[n];
		Map<Edge, Number> flowMap;
		for (i = 1; i < n; i++) {
			/*dump();
			maxFlow.evaluate();
			flow[i] = maxFlow.getMaxFlow();*/
			Collection<Edge> edges = null;
			for (Edge e : edges) {
				adjustTree(tree, e);
			}
		}
	}
	
	private void adjustTree(Vertex[] tree, Edge e) {
		// Adjust the tree such that outVertex of e now points to inVertex of e
		// Do this by putting the outVertex on tree[inVertex]
		// May not work with an array ...
	}

	public Cluster<Vertex> getCluster(Vertex i) {
		// TODO implement
		return null;
	}
	
	/**
	 * Contraction of the clusters to a vertex x which is still connected to all the other vertices of the original graph.
	 * @param graph
	 * @param clusters The clusters which should be contracted
	 * @return
	 */
	public Graph contract(Graph graph, List<Set<Vertex>> clusters) {
		Graph g = new TinkerGraph();
		// V' = {V-S,x}
		for (Vertex v : graph.getVertices())
			if (!vertexInClusters(v, clusters))
				g.addVertex(v);
		Vertex x = g.addVertex(null);
		// TODO define local clustering interface
		ClusteringDataInterface local = null;
		// Copy the entries of A, involving both the vertices from V - S, to A'
		for (Vertex v : g.getVertices())
			for (Vertex u : g.getVertices())
				local.setAdjacency(v, u, clustering.getAdjacency(v, u));
		// A'(i, n) = ICW(i) + OCW(i) -	sum A'(i, j) with j between 1 and n
		for (Vertex v : g.getVertices()) {
			double sum = 0;
			for (Vertex u : g.getVertices())
				if (u != x)
					sum += local.getAdjacency(v, u);
			local.setAdjacency(v, x, clustering.getIcw(v) + clustering.getOcw(v) - sum);
		}
		// Extract E' from A'
		for (Vertex v : graph.getVertices())
			for (Vertex u : graph.getVertices())
				addEdgeWithWeight(g, v, u, local.getAdjacency(v, u));
		return g;
	}
	
	
	/**
	 * Contraction of the graph of all clusters that are not defined by clusters.
	 * So we get a new graph containing the vertices from clusters and a new vertex x.
	 * @param clusters The clusters which shouldn't be contracted
	 * @return
	 */
	public Graph contractMattie(ClusteringDataInterface local, Cluster<Vertex>... clusters) {
		Graph g = new TinkerGraph();
		for (Cluster<Vertex> cluster : clusters)
			for (Vertex v : cluster)
				g.addVertex(v);

		// Copy the entries of A, involving both the vertices from V - S, to A'
		for (Vertex v : g.getVertices())
			for (Vertex u : g.getVertices())
				local.setAdjacency(v, u, clustering.getAdjacency(v, u));

		Vertex x = g.addVertex(null);
		
		// A'(i, n) = ICW(i) + OCW(i) -	sum A'(i, j) with j between 1 and n
		for (Vertex v : g.getVertices()) {
			double sum = 0;
			for (Vertex u : g.getVertices())
				if (u != x)
					sum += local.getAdjacency(v, u);
			local.setAdjacency(v, x, clustering.getIcw(v) + clustering.getOcw(v) - sum);
		}
		// Extract E' from A'
		for (Vertex v : graph.getVertices())
			for (Vertex u : graph.getVertices())
				addEdgeWithWeight(g, v, u, local.getAdjacency(v, u));
		
		return g;
	}

	private boolean vertexInClusters(Vertex v, List<Set<Vertex>> clusters) {
		for (Set<Vertex> set : clusters)
			if (set.contains(v))
				return true;
		return false;
	}
	
	private Edge addEdgeWithWeight(Graph g, Vertex v, Vertex u, double weight) {
		Edge e = g.addEdge(null, v, u, "similarity");
		e.setProperty("weight", weight);
		return e;
	}

}

interface Cluster<E> extends Iterable<E> {
	
	int size();
	
}