/**
 * 
 */
package clustering.testing;


import java.util.ArrayList;
import java.util.Collection;
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

import clustering.CaseThree;
import clustering.ClusteringUtility;
import clustering.DynamicMinCutClustering;
import clustering.MagicDataRetrieval;

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
	public void testMaxFlowAlgorithm() {
		Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		Vertex v5 = g.addVertex(5);
		Vertex v6 = g.addVertex(6);
		Edge e1 = g.addEdge(1, v1, v2, "similarity");
		e1.setProperty("weight", 0.05);
		Edge e2 = g.addEdge(2, v2, v3, "similarity");
		e2.setProperty("weight", 0.1);
		Edge e3 = g.addEdge(3, v1, v6, "similarity");
		e3.setProperty("weight", 0.15);
		Edge e4 = g.addEdge(4, v4, v3, "similarity");
		e4.setProperty("weight", 0.05);
		Edge e5 = g.addEdge(5, v5, v4, "similarity");
		e5.setProperty("weight", 0.1);
		Edge e6 = g.addEdge(6, v6, v5, "similarity");
		e6.setProperty("weight", 0.05);
		Edge e7 = g.addEdge(7, v6, v2, "similarity");
		e7.setProperty("weight", 0.05);
		Edge e8 = g.addEdge(8, v3, v5, "similarity");
		e8.setProperty("weight", 0.05);
		
		// We don't want to work with directed graphs ...
		Edge temp;
		for (int i = 1; i <=  8; i++) {
			temp = g.getEdge(i);
			g.addEdge(null, temp.getInVertex(), temp.getOutVertex(), "s").setProperty("weight", temp.getProperty("weight"));
		}
		
		Object[] result = ClusteringUtility.getMaxFlow(g, v1, v4, ClusteringUtility.createAdjacencyInterface(g));
		
		assertEquals(0.15, result[0]);
		Collection<Edge> c = (Collection<Edge>) result[1];
		
		assertTrue(c.size() == 3);
		assertTrue(c.contains(e1));
		assertTrue(c.contains(e7));
		assertTrue(c.contains(e6));
	}

	@Test
	public void testGusfield() {
		Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		g.addEdge(1, v1, v2, "s").setProperty("weight", 1d);
		g.addEdge(2, v2, v3, "s").setProperty("weight", 2d);
		g.addEdge(3, v3, v4, "s").setProperty("weight", 2d);
		g.addEdge(4, v2, v4, "s").setProperty("weight", 3d);
		g.addEdge(null, v2, v1, "s").setProperty("weight", 1d);
		g.addEdge(null, v3, v2, "s").setProperty("weight", 2d);
		g.addEdge(null, v4, v3, "s").setProperty("weight", 2d);
		g.addEdge(null, v4, v2, "s").setProperty("weight", 3d);
		
		Graph t = ClusteringUtility.sequentialGusfieldAlgorithm(g);
		// TODO is this graph unique ? I don't think so... What can we test ?
		int i = 0;
		for (Edge e : t.getEdges())
			i++;
		assertEquals(i, 3);
		for (Edge e : t.getEdges()) {
			if (e.getInVertex() == v1)
				assertEquals(e.getOutVertex(), v2);
			if (e.getOutVertex() == v1)
				assertEquals(e.getInVertex(), v2);
			if (e.getInVertex() == v4)
				assertEquals(e.getOutVertex(), v3);
			if (e.getOutVertex() == v4)
				assertEquals(e.getInVertex(), v3);
		}
	}
	
	@Test
	public void testCalculateClusterAdjacency() {
		Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		Vertex v5 = g.addVertex(5);
		g.addEdge(1, v1, v2, "s").setProperty("weight", 1d);
		g.addEdge(2, v2, v3, "s").setProperty("weight", 2d);
		g.addEdge(3, v5, v4, "s").setProperty("weight", 2d);
		Set<Vertex> cluster = ClusteringUtility.calculateCluster(g, v1, ClusteringUtility.createAdjacencyInterface(g), new HashSet<Vertex>());
		assertTrue(cluster.contains(v1));
		assertTrue(cluster.contains(v2));
		assertTrue(cluster.contains(v3));
		assertFalse(cluster.contains(v4));
		assertFalse(cluster.contains(v5));
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
	public void testCalculateComponents() {
		Graph g = new TinkerGraph();
		Vertex v1 = g.addVertex(1);
		Vertex v2 = g.addVertex(2);
		Vertex v3 = g.addVertex(3);
		Vertex v4 = g.addVertex(4);
		Vertex v5 = g.addVertex(5);
		Vertex v6 = g.addVertex(6);
		Vertex v7 = g.addVertex(7);
		g.addEdge(null, v1, v2, "s").setProperty("weight", 1d);
		g.addEdge(null, v2, v3, "s").setProperty("weight", 1d);
		g.addEdge(null, v1, v3, "s").setProperty("weight", 1d);
		g.addEdge(null, v1, v4, "s").setProperty("weight", 1d);
		g.addEdge(null, v5, v6, "s").setProperty("weight", 1d);
		g.addEdge(null, v6, v5, "s").setProperty("weight", 1d);
		/*Set<Set<Vertex>> setset = ClusteringUtility.calculateComponents(g);
		for (Set<Vertex> set : setset)
			assertTrue((set.size() == 4 && set.contains(v1) && set.contains(v2) && set.contains(v3) && set.contains(v4)) 
					|| (set.size() == 2 && set.contains(v5) && set.contains(v6)) || (set.size() == 1 &&set.contains(v7)));*/
	}
	
	@Test
	public void testCaseThree() {
		Set<Integer> c2 = new HashSet<Integer>();
		int numberVertices = 5;
		Set<Integer> c1 = new HashSet<Integer>();
		c1.add(1);
		c1.add(2);
		c1.add(0);
		c2.add(3);
		c2.add(4);

		final double [] icw = new double[] {0.3d,0.7d,0.8d,0.4d,0.4d};
		final double [] ocw = new double[] {0.0d,0.3d,0.8d,1.1d,0.0d};
		double adj[][] = new double [5][5];
		adj[0][1] = 0.1d;
		adj[0][2] = 0.2d;
		adj[1][2] = 0.6d;
		adj[1][3] = 0.3d;
		adj[2][3] = 0.8d;
		adj[3][4] = 0.4d;
		adj[1][0] = 0.1d;
		adj[2][0] = 0.2d;
		adj[2][1] = 0.6d;
		adj[3][1] = 0.3d;
		adj[3][2] = 0.8d;
		adj[4][3] = 0.4d;
		final double a[][] = adj.clone();
		MagicDataRetrieval mdr = new MagicDataRetrieval() {

			
			@Override
			public double getIcw(int v) {
				return icw[v];
			}

			@Override
			public double getOcw(int v) {
				return ocw[v];
			}

			@Override
			public void setIcw(int v, double value) {
				icw[v] = value;
			}

			@Override
			public void setOcw(int v, double value) {
				ocw[v] = value;
			}

			@Override
			public void increaseIcw(int v, double amount) {
				icw[v] += amount;
			}

			@Override
			public void increaseOcw(int v, double amount) {
				ocw[v] += amount;				
			}

			@Override
			public double getAdjacency(int v, int u) {
				return a[v][u];
			}

			@Override
			public void setAdjacency(int v, int u, double weight) {
				a[v][u] = weight;
			}

			@Override
			public void increaseAdjacency(int v, int u, double weight) {
				a[v][u] += weight;
			}
			
		};
		CaseThree c3 = new CaseThree(c1, c2, numberVertices, 0.3, mdr);
		Set<Set<Integer>> result = c3.run();
		assertNotNull(result);
	}
	
	@Test
	public void testCaseThreeMinProblem() {
		Set<Integer> c2 = new HashSet<Integer>();
		int numberVertices = 2;
		Set<Integer> c1 = new HashSet<Integer>();
		c1.add(1);
		c2.add(0);

		final double [] icw = new double[] {0,0};
		final double [] ocw = new double[] {0.1,0.1};
		double adj[][] = new double [3][3];
		adj[0][1] = 0.1d;
		adj[1][0] = 0.1d;
		adj[0][2] = 0.01;
		adj[2][0] = 0.01;
		final double a[][] = adj.clone();
		MagicDataRetrieval mdr = new MagicDataRetrieval() {

			
			@Override
			public double getIcw(int v) {
				return icw[v];
			}

			@Override
			public double getOcw(int v) {
				return ocw[v];
			}

			@Override
			public void setIcw(int v, double value) {
				icw[v] = value;
			}

			@Override
			public void setOcw(int v, double value) {
				ocw[v] = value;
			}

			@Override
			public void increaseIcw(int v, double amount) {
				icw[v] += amount;
			}

			@Override
			public void increaseOcw(int v, double amount) {
				ocw[v] += amount;				
			}

			@Override
			public double getAdjacency(int v, int u) {
				return a[v][u];
			}

			@Override
			public void setAdjacency(int v, int u, double weight) {
				a[v][u] = weight;
				a[u][v] = weight;
			}

			@Override
			public void increaseAdjacency(int v, int u, double weight) {
				a[v][u] += weight;
				a[u][v] += weight;
			}
			
		};
		CaseThree c3 = new CaseThree(c1, c2, numberVertices, 0.03, mdr);
		Set<Set<Integer>> result = c3.run();
		// 3 as there is also an empty set
		assertTrue(result.size() == 3);
		c3 = new CaseThree(c1, c2, numberVertices, 0.03, mdr);
		result = c3.run();
		assertTrue(result.size() == 2);
	}
	
	@Test
	public void testSequentialGusfield() {
		
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
