package clustering;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
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

	public static void main(String[] args) {
		Gson gson = new Gson();
		Type collectionType = new TypeToken<Set<Integer>>(){}.getType();
		Set<Integer> c1 = gson.fromJson(args[0], collectionType);
		Set<Integer> c2 = gson.fromJson(args[1], collectionType);
		int V = gson.fromJson(args[2], int.class);
		double alpha = gson.fromJson(args[3], double.class);
		Set<Set<Integer>> clusters = 
			new CaseThree(c1, c2, V, alpha, new RedisDataRetrieval()).run();
		System.out.println(gson.toJson(clusters));
	}
	
	public CaseThree(Set<Integer> c1, Set<Integer> c2, int numberVertices, double alpha, MagicDataRetrieval data) {
		cluster1 = c1;
		cluster2 = c2;
		v = numberVertices;
		this.alpha = alpha;
		x = -1;
		t = -2;
		this.data = data;
	}
	
	public Set<Set<Integer>> run() {
		LocalDataRetrieval local = new LocalDataRetrieval();
		// CONTRACT(cluster1, cluster2)
		Graph g = new TinkerGraph();
		g.addVertex(t);
		g.addVertex(x);
		double sum;
		double temp;
		// Copying entries of A to A' and calculating the weight of the edges going to outside clusters
		// First for all vertices in cluster1
		for (int i : cluster1) {
			sum = 0;
			for (int i1 : cluster1) {
				temp = data.getAdjacency(i, i1);
				local.setAdjacency(i, i1, temp);
				sum += temp;
			}
			for (int j : cluster2) {
				local.setAdjacency(i, j, data.getAdjacency(i, j));
				sum += local.getAdjacency(i, j);
			}
			sum = data.getIcw(i) + data.getOcw(i) - sum;
			local.setAdjacency(i, x, sum);
			local.setAdjacency(x, i, sum);
		}
		// Then for all vertices in cluster2
		for (int i : cluster2) {
			sum = 0;
			for (int i1 : cluster2) {
				local.setAdjacency(i, i1, data.getAdjacency(i, i1));
				sum += local.getAdjacency(i, i1);
			}
			for (int j : cluster1) {
				local.setAdjacency(i, j, data.getAdjacency(i, j));
				sum += local.getAdjacency(i, j);
			}
			sum = data.getIcw(i) + data.getOcw(i) - sum;
			local.setAdjacency(i, x, sum);
			local.setAdjacency(x, i, sum);
		}
		// Adding the new vertices to a temporary graph g and adding an artificial sink t
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
		// Connecting the sink t with the contracted clusters, represented by the single vertex x
		local.setAdjacency(t, x, v - cluster1.size() - cluster2.size());
		local.setAdjacency(x, t, v - cluster1.size() - cluster2.size());
		
		// Little hack because sequentialGusFieldAlgorithm uses the edges in the graph AND the adjacencymatrix ...
		for (Vertex i : g.getVertices())
			for (Vertex j : g.getVertices())
				if (local.getAdjacency(i, j) > 0)
					g.addEdge(null, i, j, "s").setProperty("weight", local.getAdjacency(i, j));
		
		// Calculate min-cut tree
		Graph tree = ClusteringUtility.sequentialGusfieldAlgorithm(g, local);
		
		tree.removeVertex(tree.getVertex(t));
		
		Set<Set<Integer>> result = ClusteringUtility.calculateComponents(tree);
		for (Set<Integer> set : result)
			if (set.contains(x))
				set.remove(x);
		
		Set<Integer> newFriends;
		Set<Integer> exFriends;
		for (int i : cluster1) {
			newFriends = findCluster(i, result);
			newFriends.removeAll(cluster1);
			exFriends = cluster1;
			exFriends.removeAll(newFriends);
			sum = 0;
			for (int ex : exFriends)
				sum -= local.getAdjacency(i, ex);
			for (int newF : newFriends)
				sum += local.getAdjacency(i, newF);
			data.increaseIcw(i, sum);
			data.increaseOcw(i, -sum);
		}

		for (int i : cluster2) {
			newFriends = findCluster(i, result);
			newFriends.removeAll(cluster2);
			exFriends = cluster2;
			exFriends.removeAll(newFriends);
			sum = 0;
			for (int ex : exFriends)
				sum -= local.getAdjacency(i, ex);
			for (int newF : newFriends)
				sum += local.getAdjacency(i, newF);
			data.increaseIcw(i, sum);
			data.increaseOcw(i, -sum);
		}
		
		return result;
	}

	private Set<Integer> findCluster(int i, Set<Set<Integer>> result) {
		Set<Integer> r = new HashSet<Integer>();
		for (Set<Integer> set : result)
			if (set.contains(i))
				r.addAll(set);
		if (r.size() > 0)
			return r;
		// This should never happen as every index should be in one cluster
		throw new NullPointerException();
	}

}

class LocalDataRetrieval implements MagicDataRetrieval, AdjacencyInterface {
	
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
		if (!adjacency.containsKey(u))
			adjacency.put(u, new HashMap<Integer, Double>());
		adjacency.get(u).put(v, weight);
	}

	@Override
	public void increaseAdjacency(int v, int u, double weight) {
		setAdjacency(v, u, weight + getAdjacency(v, u));
	}

	@Override
	public double getAdjacency(Vertex v, Vertex u) {
		return this.getAdjacency(Integer.parseInt((String)v.getId()), Integer.parseInt((String)u.getId()));
	}

	@Override
	public void setAdjacency(Vertex v, Vertex u, double weight) {
		this.setAdjacency(Integer.parseInt((String)v.getId()), Integer.parseInt((String)u.getId()), weight);
	}

	@Override
	public void increaseAdjacency(Vertex v, Vertex u, double weight) {
		this.increaseAdjacency(Integer.parseInt((String)v.getId()), Integer.parseInt((String)u.getId()), weight);
	}
	
}
