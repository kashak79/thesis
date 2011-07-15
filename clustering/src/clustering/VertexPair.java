package clustering;

public class VertexPair<V> {
	
	private V source;
	private V destination;

	public VertexPair(V source, V destination) {
		this.source = source;
		this.destination = destination;
	}

	public V getSource() {
		return source;
	}

	public V getDestination() {
		return destination;
	}

}
