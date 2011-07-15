/**
 * 
 */
package clustering.testing;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import junit.framework.TestCase;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import clustering.ClusteringUtility;
import clustering.DynamicMinCutClustering;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;
import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph;

/**
 * @author Simon Buelens
 *
 */
public class DynamicMinCutClusteringTestCase extends TestCase {

	Graph graph;
	DynamicMinCutClustering dmcc;
	
	@Test
	public void testWeight() {
		graph = new TinkerGraph();
		Vertex v1 = graph.addVertex(null);
		Vertex v2 = graph.addVertex(null);
		Edge e = graph.addEdge(2, v1, v2, "similarity");
		assertEquals(ClusteringUtility.getWeight(e), 0d);
		e.setProperty("weight", 0.5);
		assertEquals(ClusteringUtility.getWeight(e), 0.5);
	}
	
	@Test
	public void testGetAllWeights() {
		graph = this.createSimpleGraph();
		DynamicMinCutClustering dmcc = new DynamicMinCutClustering(graph, 0);
		Set<Vertex> cluster = new HashSet<Vertex>();
		cluster.add(graph.getVertex(1));
		cluster.add(graph.getVertex(2));
		cluster.add(graph.getVertex(3));
		// Weights from edges coming from v(1) to other vertices in the same cluster: v2 and v3
		assertEquals(ClusteringUtility.sumWeights(dmcc.getAdjacency(), graph.getVertex(1), cluster), 0.8);
		// Weight from vertex not connected to cluster should be 0
		assertEquals(ClusteringUtility.sumWeights(dmcc.getAdjacency(), graph.getVertex(4), cluster), 0.0);
	}
	
	@Test
	/**
	 * Testing the algorithm as explained in pseudocode in the paper, figure 3
	 */
	public void testIntraClusterEdgeAddition() {
		graph = this.createSimpleGraph();
		DynamicMinCutClustering dmcc = new DynamicMinCutClustering(graph, 0);
		Set<Vertex> cluster = new HashSet<Vertex>();
		Vertex v1 = graph.getVertex(1);
		Vertex v2 = graph.getVertex(2);
		Vertex v3 = graph.getVertex(3);
		cluster.add(v1);
		cluster.add(v2);
		cluster.add(v3);
		Edge e = graph.addEdge(null, v2, v1, "similarity");
		double weight = 0.4;
		e.setProperty("weight", weight);
		double adj_b = dmcc.getAdjacency(e.getOutVertex(), e.getInVertex());
		double icw_b_i = dmcc.getIcw(e.getOutVertex());
		double icw_b_j = dmcc.getIcw(e.getInVertex());
		dmcc.intraClusterEdgeAddition(e);
		double adj = dmcc.getAdjacency(e.getOutVertex(), e.getInVertex());
		double icw_i = dmcc.getIcw(e.getOutVertex());
		double icw_j = dmcc.getIcw(e.getInVertex());
		assertEquals(adj_b + weight, adj);
		assertEquals(icw_b_j + weight, icw_j);
		assertEquals(icw_b_i + weight, icw_i);
	}
	
	@Test
	/**
	 * algorithm paper figure 4
	 */
	public void testMergeOfTwoClusters() {
		graph = this.createSimpleGraph();
		Set<Vertex> cluster1 = new HashSet<Vertex>();
		Set<Vertex> cluster2 = new HashSet<Vertex>();
		cluster1.add(graph.getVertex(1));
		cluster1.add(graph.getVertex(2));
		cluster1.add(graph.getVertex(3));
		cluster2.add(graph.getVertex(4));
		cluster2.add(graph.getVertex(5));
		List<Set<Vertex>> list = new ArrayList<Set<Vertex>>();
		list.add(cluster1);
		list.add(cluster2);
		DynamicMinCutClustering dmcc = new DynamicMinCutClustering(graph, 0, list);
		// TODO define elements of cluster1 and cluster2
		Map<Vertex, Double> icw_1 = new HashMap<Vertex, Double>();
		Map<Vertex, Double> ocw_1 = new HashMap<Vertex, Double>();
		Map<Vertex, Double> icw_2 = new HashMap<Vertex, Double>();
		Map<Vertex, Double> ocw_2 = new HashMap<Vertex, Double>();
		for (Vertex v : cluster1) {
			icw_1.put(v, dmcc.getIcw(v));
			ocw_1.put(v, dmcc.getOcw(v));
		}
		for (Vertex v : cluster2) {
			icw_2.put(v, dmcc.getIcw(v));
			ocw_2.put(v, dmcc.getOcw(v));
		}
		
		Set<Vertex> merged = dmcc.merge(cluster1, cluster2);
		
		Map<Vertex, Double> icw_1_n = new HashMap<Vertex, Double>(icw_1);
		Map<Vertex, Double> ocw_1_n = new HashMap<Vertex, Double>(ocw_1);
		Map<Vertex, Double> icw_2_n = new HashMap<Vertex, Double>(icw_2);
		Map<Vertex, Double> ocw_2_n = new HashMap<Vertex, Double>(ocw_2);
		//check ICW and OCW of elements in cluster1
		for (Vertex v : cluster1) {
			for (Vertex u : cluster2) {
				//Check shouldn't be necessairy as we just copied all values of the original map
				/*if (!icw_1_n.containsKey(v))
					icw_1_n.put(v, 0d);*/
				icw_1_n.put(v, icw_1.get(v) + dmcc.getAdjacency(v, u));
				//Same
				/*if (!ocw_1_n.containsKey(v))
					ocw_1_n.put(v, 0d);*/
				ocw_1_n.put(v, ocw_1_n.get(v) + dmcc.getAdjacency(v, u));
			}
		}
		//check ICW and OCW of elements in cluster2
		for (Vertex v : cluster2) {
			for (Vertex u : cluster1) {
				//Check shouldn't be necessairy as we just copied all values of the original map
				/*if (!icw_1_n.containsKey(v))
					icw_1_n.put(v, 0d);*/
				icw_2_n.put(v, icw_2.get(v) + dmcc.getAdjacency(v, u));
				//Same
				/*if (!ocw_1_n.containsKey(v))
					ocw_1_n.put(v, 0d);*/
				ocw_2_n.put(v, ocw_2_n.get(v) + dmcc.getAdjacency(v, u));
			}
		}
		
		Map<Vertex, Double> icw_n = new HashMap<Vertex, Double>(icw_1_n);
		icw_n.putAll(icw_2_n);
		Map<Vertex, Double> ocw_n = new HashMap<Vertex, Double>(ocw_1_n);
		ocw_n.putAll(ocw_2_n);
		for (Vertex v : merged) {
			assertEquals(dmcc.getIcw(v), icw_n.get(v));
			assertEquals(dmcc.getOcw(v), ocw_n.get(v));
		}
		
	}
	
	@Test
	public void testContractClusters() {
		
	}
	
	@Test
	public void testInterClusterEdgeAddition() {
		
	}
	
	@Test
	public void testIntraClusterEdgeDeletion() {
		
	}
	
	@Test
	public void testInterClusterEdgeDeletion() {
		
	}
	
	@Test
	public void testMultipleEdgeAdditions() {
		
	}
	
	private Graph createSimpleGraph() {
		Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		Vertex v5 = g.addVertex(5);
		Vertex v6 = g.addVertex(6);
		Vertex v7 = g.addVertex(7);
		Edge e1 = g.addEdge(null, v1, v2, "similarity");
		e1.setProperty("weight", 0.5);
		Edge e2 = g.addEdge(null, v2, v3, "similarity");
		e2.setProperty("weight", 0.2);
		Edge e3 = g.addEdge(null, v1, v3, "similarity");
		e3.setProperty("weight", 0.3);
		Edge e4 = g.addEdge(null, v4, v5, "similarity");
		e4.setProperty("weight", 0.1);
		Edge e5 = g.addEdge(null, v4, v5, "similarity");
		e5.setProperty("weight", 0.25);
		return g;
	}
	
	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}

}
