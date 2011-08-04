package clustering;


import java.util.Set;

import com.tinkerpop.blueprints.pgm.Vertex;

public interface ClusteringDataInterface extends AdjacencyInterface {
	
	double getIcw(Vertex v);
	
	double getOcw(Vertex v);
	
	void setIcw(Vertex v, double value);
	
	void setOcw(Vertex v, double value);
	
	void increaseIcw(Vertex v, double amount);
	
	void increaseOcw(Vertex v, double amount);
	
	Cluster<Vertex> getCluster(Vertex v);
	
	Set<Cluster<Vertex>> getClusters();
	
	void addCluster(Cluster<Vertex> cluster);
	
	void removeCluster(Cluster<Vertex> cluster);

}
