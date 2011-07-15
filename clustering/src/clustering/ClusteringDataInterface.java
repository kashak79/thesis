package clustering;

import com.tinkerpop.blueprints.pgm.Vertex;

public interface ClusteringDataInterface {
	
	double getIcw(Vertex v);
	
	double getOcw(Vertex v);
	
	void setIcw(Vertex v, double value);
	
	void setOcw(Vertex v, double value);
	
	void increaseIcw(Vertex v, double amount);
	
	void increaseOcw(Vertex v, double amount);
	
	double getAdjacency(Vertex v, Vertex u);
	
	void setAdjacency(Vertex v, Vertex u, double weight);
	
	void increaseAdjacency(Vertex v, Vertex u, double weight);

}
