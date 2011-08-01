package clustering;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.swing.JFrame;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;
import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph;

import edu.uci.ics.jung.algorithms.layout.FRLayout;
import edu.uci.ics.jung.visualization.VisualizationViewer;
import edu.uci.ics.jung.visualization.decorators.ToStringLabeller;

public class DynMinCutClustering {
	
	Graph graph = null;
	ClusteringDataInterface clustering;
	int n;
	
	public DynMinCutClustering(ClusteringDataInterface clustering) {
		this.clustering = clustering;
		// TODO find quick way to find number of vertices in graph
		n = 0;
	}
	
	public void intraClusterEdgeAddition(Vertex i, Vertex j, double weight) {
		clustering.increaseAdjacency(i, j, weight);
		clustering.increaseIcw(i, weight);
		clustering.increaseIcw(j, weight);
	}
	
	public void interClusterEdgeAddition(Vertex i, Vertex j, double weight, double alpha) {
		Cluster<Vertex> cluster1 = getCluster(i);
		Cluster<Vertex> cluster2 = getCluster(j);
		if (case1formula(cluster1, weight) <= alpha && case1formula(cluster2, weight) <= alpha ) {
			clustering.increaseAdjacency(i, j, weight);
			clustering.increaseOcw(i, weight);
			clustering.increaseOcw(j, weight);
		}
		else if ((2.0 * cutValue(cluster1, cluster2) / n) >= alpha) {
			Cluster<Vertex> d = merge(cluster1, cluster2);
			// TODO : make sure the clusters 1 and 2 are gone and d is added!
			clustering.addCluster(d);
			clustering.removeCluster(cluster1);
			clustering.removeCluster(cluster2);
		}
		else
			case3(i, j, cluster1, cluster2, alpha);
	}

	private double cutValue(Cluster<Vertex> cluster1, Cluster<Vertex> cluster2) {
		double sum = 0;
		for (Vertex v : cluster1)
			for (Vertex u : cluster2)
				sum += clustering.getAdjacency(v, u);
		return 0;
	}

	public Cluster<Vertex> merge(Cluster<Vertex> cluster1, Cluster<Vertex> cluster2) {
		Cluster<Vertex> d = clusterMerge(cluster1, cluster2);
		double sum;
		for (Vertex v : cluster1) {
			sum = sumWeights(v, cluster1);
			clustering.increaseIcw(v, sum);
			clustering.increaseOcw(v, -sum);
		}
		for (Vertex v : cluster2) {
			sum = sumWeights(v, cluster2);
			clustering.increaseIcw(v, sum);
			clustering.increaseOcw(v, -sum);
		}
		return d;
	}
	
	/**
	 * The actual merging of the clusters in the graph itself
	 * @param cluster1
	 * @param cluster2
	 * @return
	 */
	private Cluster<Vertex> clusterMerge(Cluster<Vertex> cluster1,
			Cluster<Vertex> cluster2) {
		// TODO Auto-generated method stub
		return null;
	}

	public double sumWeights(Vertex v, Cluster<Vertex> cluster1) {
		double sum = 0;
		for (Vertex u : cluster1)
			sum += clustering.getAdjacency(u, v);
		return sum;
	}

	private double case1formula(Cluster<Vertex> cluster1, double weight) {
		// TODO Auto-generated method stub
		return 0;
	} 

	public void case3(Vertex i, Vertex j, Cluster<Vertex> cluster1, Cluster<Vertex> cluster2, double alpha) {
		ClusteringDataInterface cdi = null;
		Graph g = contractMattie(-1, cdi, cluster1, cluster2);
		
		Vertex t = graph.addVertex(null);
		
		// Add an artificial SINK t: connect v to t, for all v in cluster1 or cluster2 with edge of weight alpha
		for (Vertex v : cluster1) {
			this.addEdgeWithWeight(g, v, t, alpha);
			this.addEdgeWithWeight(g, t, v, alpha);
		}
		for (Vertex v : cluster2) {
			this.addEdgeWithWeight(g, v, t, alpha);
			this.addEdgeWithWeight(g, t, v, alpha);
		}
		// Also connect this sink to the vertex x we added in the contract step
		this.addEdgeWithWeight(g, t, g.getVertex(-1), alpha * (n - cluster1.size() - cluster2.size()));
		this.addEdgeWithWeight(g, g.getVertex(-1), t, alpha * (n - cluster1.size() - cluster2.size()));

		Graph T = ClusteringUtility.sequentialGusfieldAlgorithm(g);
		
		T.removeVertex(t);
		Set<Set<Vertex>> clusters = ClusteringUtility.calculateComponents(T);
		
		// TODO make Cluster objects from Set ?
		
		for (Cluster<Vertex> cluster : clusters)
			clustering.addCluster(cluster);
		clustering.removeCluster(cluster1);
		clustering.removeCluster(cluster2);
	}
	
	public void case3(Object v1, Object v2, Object idCluster1, Object idCluster2, double alpha) {
		Vertex v = graph.getVertex(v1);
		Vertex u = graph.getVertex(v2);
		Set<Vertex> cluster1 = new HashSet<Vertex>();
		for (Edge e : graph.getVertex(idCluster1).getInEdges("instance_of"))
			cluster1.add(e.getOutVertex());
		Set<Vertex> cluster2 = new HashSet<Vertex>();
		for (Edge e : graph.getVertex(idCluster2).getInEdges("instance_of"))
			cluster1.add(e.getOutVertex());
		this.case3(v, u, cluster1, cluster2, alpha);
	}

	public Cluster<Vertex> getCluster(Vertex i) {
		// TODO implement
		return null;
	}
	
	/**
	 * Contraction of the graph of all clusters that are not defined by clusters.
	 * So we get a new graph containing the vertices from clusters and a new vertex x.
	 * @param id the id we will use to indicate the contracted vertex, allowing to extract it later from the graph
	 * @param local a ClusteringDataInterface object used to store and retrieve weights
	 * @param clusters The clusters which shouldn't be contracted
	 * @return
	 */
	public Graph contractMattie(int id, ClusteringDataInterface local, Cluster<Vertex>... clusters) {
		Graph g = new TinkerGraph();
		for (Cluster<Vertex> cluster : clusters)
			for (Vertex v : cluster)
				g.addVertex(v);

		// Copy the entries of A, involving both the vertices from V - S, to A'
		for (Vertex v : g.getVertices())
			for (Vertex u : g.getVertices())
				local.setAdjacency(v, u, clustering.getAdjacency(v, u));

		// using id will allow us to extract this vertex later
		Vertex x = g.addVertex(id);
		
		// A'(i, n) = ICW(i) + OCW(i) -	sum A'(i, j) with j between 1 and n
		for (Vertex v : g.getVertices()) {
			double sum = 0;
			for (Vertex u : g.getVertices())
				if (u != x)
					sum += local.getAdjacency(v, u);
			local.setAdjacency(v, x, clustering.getIcw(v) + clustering.getOcw(v) - sum);
		}
		// Extract E' from A'
		for (Vertex v : g.getVertices())
			for (Vertex u : g.getVertices())
				if (local.getAdjacency(v, u) > 0)
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
	
	public static void main(String[] args) throws IOException 
    {
        JFrame jf = new JFrame();

        Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		Vertex v5 = g.addVertex(5);
		Vertex v6 = g.addVertex(6);
		Edge e1 = g.addEdge(null, v1, v2, "similarity");
		e1.setProperty("weight", 0.05);
		Edge e2 = g.addEdge(null, v2, v3, "similarity");
		e2.setProperty("weight", 0.06);
		Edge e3 = g.addEdge(null, v1, v6, "similarity");
		e3.setProperty("weight", 0.15);
		Edge e4 = g.addEdge(null, v3, v4, "similarity");
		e4.setProperty("weight", 0.05);
		Edge e5 = g.addEdge(null, v5, v4, "similarity");
		e5.setProperty("weight", 0.1);
		Edge e6 = g.addEdge(null, v6, v5, "similarity");
		e6.setProperty("weight", 0.05);
		Edge e7 = g.addEdge(null, v6, v2, "similarity");
		e7.setProperty("weight", 0.05);
		Edge e8 = g.addEdge(null, v3, v5, "similarity");
		e8.setProperty("weight", 0.05);
		//g.addEdge(null, v1, v3, "similarity").setProperty("weight", 0.4);
		g.addEdge(null, v2, v1, "similarity").setProperty("weight", 0.05);
		g.addEdge(null, v3, v2, "similarity").setProperty("weight", 0.06);
		g.addEdge(null, v6, v1, "similarity").setProperty("weight", 0.15);
		g.addEdge(null, v4, v3, "similarity").setProperty("weight", 0.05);
		g.addEdge(null, v4, v5, "similarity").setProperty("weight", 0.1);
		g.addEdge(null, v5, v6, "similarity").setProperty("weight", 0.05);
		g.addEdge(null, v2, v6, "similarity").setProperty("weight", 0.05);
		g.addEdge(null, v5, v3, "similarity").setProperty("weight", 0.05);
		//g.addEdge(null, v3, v1, "similarity").setProperty("weight", 0.4);
		
		DynMinCutClustering dmcc = new DynMinCutClustering(null);
		//VisualizationViewer vv = new VisualizationViewer(new FRLayout(ClusteringUtility.convertToDirectedGraph(ClusteringUtility.undirectedGraph(g))));
		Graph t = ClusteringUtility.sequentialGusfieldAlgorithm(g);
        VisualizationViewer vv = new VisualizationViewer(new FRLayout(ClusteringUtility.convertToDirectedGraph(t)));
        for (Edge e : t.getEdges())
        	System.out.println(e.getOutVertex() + " connected to " + e.getInVertex() + " with weight " + e.getProperty("weight"));
        //VisualizationViewer vv = new VisualizationViewer(new FRLayout(ClusteringUtility.convertToDirectedGraph(g)));
        vv.setVertexToolTipTransformer(new ToStringLabeller<Integer>());
        //jf.getContentPane().add(vv1);
        jf.getContentPane().add(vv);
        jf.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        jf.pack();
        jf.setVisible(true);
    }

}

interface Cluster<E> extends Iterable<E> {
	
	int size();
	
}

class MyEdge implements Edge {

	@Override
	public Object getId() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getProperty(String arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Set<String> getPropertyKeys() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object removeProperty(String arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setProperty(String arg0, Object arg1) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public Vertex getInVertex() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getLabel() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Vertex getOutVertex() {
		// TODO Auto-generated method stub
		return null;
	}
	
}