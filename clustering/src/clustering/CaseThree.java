package clustering;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import com.tinkerpop.blueprints.pgm.Graph;
import com.tinkerpop.blueprints.pgm.Vertex;
import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph;

public class CaseThree {
	
	Set<Integer> cluster1;
	Set<Integer> cluster2;
	int v;
	double alpha;
	MagicDataRetrieval data;
	int x;
	int t;
	
	public CaseThree(Set<Integer> c1, Set<Integer> c2, int numberVertices, double alpha, MagicDataRetrieval data) {
		cluster1 = c1;
		cluster2 = c2;
		v = numberVertices;
		this.alpha = alpha;
		x = -1;
		t = -2;
	}
	
	public Set<Set<Integer>> run() {
		MagicDataRetrieval local = new LocalDataRetrieval();
		// CONTRACT(cluster1, cluster2)
		Graph g = new TinkerGraph();
		g.addVertex(t);
		g.addVertex(x);
		double sum;
		for (int i : cluster1) {
			sum = 0;
			for (int j : cluster2) {
				local.setAdjacency(i, j, data.getAdjacency(i, j));
				sum += local.getAdjacency(i, j);
			}
			sum = data.getIcw(i) + data.getOcw(i) - sum;
			local.setAdjacency(i, x, sum);
			local.setAdjacency(x, i, sum);
		}
		for (int i : cluster1) {
			g.addVertex(i);
			local.setAdjacency(i, t, alpha);
			local.setAdjacency(t, i, alpha);
		}
		for (int j : cluster2) {
			g.addVertex(j);
			local.setAdjacency(j, t, alpha);
			local.setAdjacency(t, j, alpha);
		}
		local.setAdjacency(t, x, v - cluster1.size() - cluster2.size());
		local.setAdjacency(x, t, v - cluster1.size() - cluster2.size());
		
		// Calculate min-cut tree
		Graph tree = ClusteringUtility.sequentialGusfieldAlgorithm(g, null);
		
		tree.removeVertex(tree.getVertex(t));
		
		Set<Set<Integer>> result = ClusteringUtility.calculateComponents(tree);
		for (Set<Integer> set : result)
			if (set.contains(x))
				set.remove(x);
		return ClusteringUtility.calculateComponents(tree);
	}

}

class LocalDataRetrieval implements MagicDataRetrieval {
	
	Map<Integer, Map<Integer, Double>> adjacency;
	Map<Integer, Double> icw;
	Map<Integer, Double> ocw;
	
	LocalDataRetrieval() {
		adjacency = new HashMap<Integer, Map<Integer,Double>>();
		icw = new HashMap<Integer, Double>();
		ocw = new HashMap<Integer, Double>();
	}

	@Override
	public double getIcw(int v) {
		if (icw.containsKey(v))
			return icw.get(v);
		return 0;
	}

	@Override
	public double getOcw(int v) {
		if (ocw.containsKey(v))
			return ocw.get(v);
		return 0;
	}

	@Override
	public void setIcw(int v, double value) {
		icw.put(v, value);
	}

	@Override
	public void setOcw(int v, double value) {
		ocw.put(v, value);
	}

	@Override
	public void increaseIcw(int v, double amount) {
		this.setIcw(v, this.getIcw(v) + amount);
	}

	@Override
	public void increaseOcw(int v, double amount) {
		this.setOcw(v, this.getOcw(v) + amount);
	}

	@Override
	public double getAdjacency(int v, int u) {
		if (adjacency.containsKey(v) && adjacency.get(v).containsKey(u))
			return adjacency.get(v).get(u);
		return 0;
	}

	@Override
	public void setAdjacency(int v, int u, double weight) {
		if (!adjacency.containsKey(v))
			adjacency.put(v, new HashMap<Integer, Double>());
		adjacency.get(v).put(u, weight);
	}

	@Override
	public void increaseAdjacency(int v, int u, double weight) {
		setAdjacency(v, u, weight + getAdjacency(v, u));
	}
	
}
