package clustering;

import java.util.Map;
import java.util.Set;

import cern.colt.matrix.impl.SparseDoubleMatrix2D;

import com.tinkerpop.blueprints.pgm.Edge;
import com.tinkerpop.blueprints.pgm.Vertex;

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

}
