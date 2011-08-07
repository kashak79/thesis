package clustering;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisDataRetrieval implements MagicDataRetrieval {

	private Jedis jedis;
	
	public RedisDataRetrieval() {
		JedisPool pool = new JedisPool(new JedisPoolConfig(), "localhost");
		this.jedis = pool.getResource();
	}
	
	private String a(int v1, int v2) {
		return v1<v2 ? "A:"+v1+":"+v2 : "A:"+v2+":"+v1;
	}
	
	@Override
	public double getIcw(int v) {
		String value = jedis.get("icw:"+v);
		return value==null ? 0 : Double.parseDouble(value);
	}

	@Override
	public double getOcw(int v) {
		String value = jedis.get("ocw:"+v);
		return value==null ? 0 : Double.parseDouble(value);
	}

	@Override
	public void setIcw(int v, double value) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setOcw(int v, double value) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void increaseIcw(int v, double amount) {
		jedis.incrBy("icw:"+v, (long) amount);
	}

	@Override
	public void increaseOcw(int v, double amount) {
		jedis.incrBy("ocw:"+v, (long) amount);
	}

	@Override
	public double getAdjacency(int v, int u) {
		String value = jedis.get(a(v, u));
		return value==null ? 0 : Double.parseDouble(value);
	}

	@Override
	public void setAdjacency(int v, int u, double weight) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void increaseAdjacency(int v, int u, double weight) {
		// TODO Auto-generated method stub
		
	}

}
