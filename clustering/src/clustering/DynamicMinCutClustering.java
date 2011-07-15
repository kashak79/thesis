package clustering;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import cern.colt.matrix.impl.SparseDoubleMatrix2D;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;


public class DynamicMinCutClustering {
	
	Graph graph;
	int numberVertices;
	double alpha = 0.0;
	//Transformer<E, ? extends Number> edgeWeigths;
	//Transformer<V, Set<V>> clusterer;
	//double [][] adjacency;
	//Map<VertexPair<V>, Double> adjacency;
	// TODO use id of vertex instead of vertex object itself
	// TODO examine the use of SparseDoubleMatrix2D adjacency;
	SparseDoubleMatrix2D adj;
	Map<Vertex, Map<Vertex, Double>> adjacency;
	Map<Vertex, Double> icw;
	Map<Vertex, Double> ocw;
	/**
	 * A list of all the clusters in the current graph
	 * Vertices contain a property 'cluster' which holds the
	 * index of the corresponding cluster they are in
	 */
	List<Set<Vertex>> clusters;
	//Map<Vertex, Set<Vertex>> clusters;
	
	
	public DynamicMinCutClustering(Graph graph, double alpha) {
		this(graph, alpha, createInitialClusters(graph));
		// TODO decide if necessairy to use a static algorithm here to find the initial clusters
		// probably not, as we won't actually be needing this in 'real life'
	}
	
	private static List<Set<Vertex>> createInitialClusters(Graph graph) {
		List<Set<Vertex>> clusters = new ArrayList<Set<Vertex>>();
		for (Vertex v : graph.getVertices()) {
			Set<Vertex> set = new HashSet<Vertex>();
			set.add(v);
			if (clusters.add(set))
				v.setProperty("cluster", clusters.size() - 1);
		}
		return clusters;
	}

	public DynamicMinCutClustering(Graph graph, double alpha, List<Set<Vertex>> clusters) {
		this.graph = graph;
		this.alpha = alpha;
		adjacency = calculateAdjacency();
		icw = calculateIcw();
		ocw = calculateOcw();
		//checkClusters(clusters);
		// Set the property cluster of each vertex to the index corresponding to the cluster
		for (int i = 0; i < clusters.size(); i ++)
			for (Vertex v : clusters.get(i))
				v.setProperty("cluster", i);
	}

	private Map<Vertex, Map<Vertex, Double>> calculateAdjacency() {
		Map<Vertex, Map<Vertex, Double>> adjacency = new HashMap<Vertex, Map<Vertex, Double>>();
		for (Edge e : graph.getEdges()) {
			Object w = e.getProperty("weight");
			if (w == null || !(w instanceof Number))
				continue;
			if (adjacency.get(e.getOutVertex()) == null)
				adjacency.put(e.getOutVertex(), new HashMap<Vertex, Double>());
			adjacency.get(e.getOutVertex()).put(e.getInVertex(), (Double)e.getProperty("weight"));
		}
		return adjacency;
	}

	private Map<Vertex, Double> calculateIcw() {
		// TODO choose to set it in the map or in the vertex itself
		Map<Vertex, Double> map = new HashMap<Vertex, Double>();
		double icw = 0;
		for (Vertex v : graph.getVertices()) {
			for (Vertex u : this.getCluster(v)) {
				icw += getAdjacency(v, u);
			}
			v.setProperty("icw", icw);
			map.put(v, icw);
			icw = 0;
		}
		return map;
	}

	private Map<Vertex, Double> calculateOcw() {
		// TODO choose to set it in the map or in the vertex itself
		Map<Vertex, Double> map = new HashMap<Vertex, Double>();
		double ocw = 0;
		for (Vertex v : graph.getVertices()) {
			for (Vertex u : graph.getVertices()) {
				if (!this.getCluster(v).contains(u))
					ocw += getAdjacency(v, u);
			}
			v.setProperty("ocw", ocw);
			map.put(v, ocw);
			ocw = 0;
		}
		return map;
	}

	public void edgeAdded(Edge edge/* ,Transformer<E, ? extends Number> edge_weights, Transformer<V, Set<V>> clusterer*/) {
		//this.edgeWeigths = edge_weights;
		//this.clusterer = clusterer;
		Vertex source = edge.getOutVertex();
		Vertex destination = edge.getInVertex();
		double weight = getWeight(edge);
		if (isIntraClusterEdgeAddition(edge)) {
			//return verzameling van clusters
		}
		// inter-cluster edge addition
		else {
			Set<Vertex> cluster1 = null;//clusters.get(source);
			Set<Vertex> cluster2 = null;//clusters.get(destination);
			// TODO : cluster van source & destination bepalen, dus gewoon de author verbonden met de instance van source en van destination
			if (crazyOCWFormule(cluster1, weight) <= alpha && crazyOCWFormule(cluster2, weight) <= alpha) {
				updateAdjacency(source, destination, weight);
				updateOCW(source, weight);
				updateOCW(destination, weight);
				//return verzameling van clusters
			}
			else if (formula2(cluster1, cluster2) >= alpha) {
				addCluster(merge(cluster1, cluster2));
				removeCluster(cluster1);
				removeCluster(cluster2);
			}
			else {
				case3();
			}
		}
	}
	
	public void intraClusterEdgeAddition(Edge edge) {
		Vertex source = edge.getOutVertex();
		Vertex destination = edge.getInVertex();
		double weight = getWeight(edge);
		if (weight <= 0)
			return;
		updateAdjacency(source, destination, weight);
		updateICW(source, weight);
		updateICW(destination, weight);
	}
	
	private void removeCluster(Set<Vertex> cluster1) {
		// TODO Auto-generated method stub
		
	}

	private void addCluster(Set<Vertex> merge) {
		// TODO Auto-generated method stub
		
	}

	private void case3() {
		// TODO Auto-generated method stub
		contract();
	}

	private void contract() {
		// TODO Auto-generated method stub
	}

	public Set<Vertex> merge(Set<Vertex> cluster1, Set<Vertex> cluster2) {
		Set<Vertex> d = new HashSet<Vertex>();
		d.addAll(cluster1);
		d.addAll(cluster2);
		for (Vertex v : cluster1) {
			updateICW(v, sumWeights(v, cluster1));
			updateOCW(v, -sumWeights(v, cluster1));
		}
		for (Vertex v : cluster2) {
			updateICW(v, sumWeights(v, cluster2));
			updateOCW(v, -sumWeights(v, cluster2));
		}
		return d;
	}

	private double sumWeights(Vertex v, Set<Vertex> cluster1) {
		double sum = 0;
		for (Vertex u : cluster1)
			sum += this.getAdjacency(v, u);
		return sum;
	}

	private double formula2(Set<Vertex> cluster1, Set<Vertex> cluster2) {
		// TODO Auto-generated method stub
		// TODO generate the min-cut
		return 0;
	}

	private void updateOCW(Vertex v, double weight) {
		if (ocw.get(v) == null)
			ocw.put(v, weight);
		else
			ocw.put(v, ocw.get(v) + weight);
	}

	private double crazyOCWFormule(Set<Vertex> cluster, double weight) {
		// TODO check if weight has to be added for each vertex v or just once in the beginning
		double sum = weight;
		for (Vertex v : cluster) {
			sum += ocw.get(v);
		}
		// TODO check if there is rounding happening
		return sum / (this.numberVertices - cluster.size());
	}

	private void updateICW(Vertex v, double weight) {
		if (icw.get(v) == null)
			icw.put(v, weight);
		else
			icw.put(v, icw.get(v) + weight);
	}

	private void updateAdjacency(Vertex source, Vertex dest, double weight) {
		// TODO Auto-generated method stub
		if (adjacency.get(source) == null)
			adjacency.put(source, new HashMap<Vertex, Double>());
		double prev = getAdjacency(source, dest);
		adjacency.get(source).put(dest, prev + weight);
	}

	private double getWeight(Edge edge) {
		// TODO figure out if this can give errors when it gives back null
		return (Double) edge.getProperty("weight");
	}

	private boolean isIntraClusterEdgeAddition(Edge edge) {
		// TODO Auto-generated method stub
		return false;
	}

	/**
	 * @param args
	 */ 
	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}
	public Graph getGraph() {
		return graph;
	}

	public int getNumberVertices() {
		return numberVertices;
	}

	public double getAlpha() {
		return alpha;
	}

	public SparseDoubleMatrix2D getAdj() {
		return adj;
	}

	public Map<Vertex, Map<Vertex, Double>> getAdjacency() {
		return adjacency;
	}
	
	public double getAdjacency(Vertex v, Vertex u) {
		if (adjacency.get(v) == null || adjacency.get(v).get(u) == null)
			return 0d;
		return adjacency.get(v).get(u);
	}

	public Map<Vertex, Double> getIcw() {
		return icw;
	}
	
	public double getIcw(Vertex v) {
		Object icw = v.getProperty("icw");
		if (icw != null && icw instanceof Number)
			return (Double)icw;
		return 0;		
	}

	public Map<Vertex, Double> getOcw() {
		return ocw;
	}
	
	public double getOcw(Vertex v) {
		Object ocw = v.getProperty("ocw");
		if (ocw != null && ocw instanceof Number)
			return (Double)ocw;
		return 0;		
	}

	public List<Set<Vertex>> getClusters() {
		return clusters;
	}
	
	public Set<Vertex> getCluster(Vertex v) {
		try {
			return clusters.get((Integer)v.getProperty("cluster"));
		} catch (Throwable t) {
			return new HashSet<Vertex>();
		}
	}
	
	private void setCluster(Vertex v, int index) {
		v.setProperty("cluster", index);
	}
	
	private void setIcw(Vertex v, double d) {
		v.setProperty("icw", d);
	}
	
	private void setOcw(Vertex v, double d) {
		v.setProperty("ocw", d);
	}

}
