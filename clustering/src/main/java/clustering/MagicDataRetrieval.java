package clustering;


public interface MagicDataRetrieval {	
	
	double getIcw(int v);

	double getOcw(int v);
	
	void setIcw(int v, double value);
	
	void setOcw(int v, double value);
	
	void increaseIcw(int v, double amount);
	
	void increaseOcw(int v, double amount);

	double getAdjacency(int v, int u);
	
	void setAdjacency(int v, int u, double weight);
	
	void increaseAdjacency(int v, int u, double weight);

}
