package clustering;

import com.tinkerpop.blueprints.pgm.Vertex;

public interface AdjacencyInterface {
	
	double getAdjacency(Vertex v, Vertex u);
	
	void setAdjacency(Vertex v, Vertex u, double weight);
	
	void increaseAdjacency(Vertex v, Vertex u, double weight);

}
