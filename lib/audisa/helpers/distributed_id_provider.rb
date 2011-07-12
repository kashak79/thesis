class Helpers::DistributedIdProvider

  def initialize
    @redis = Redis.new
  end

  def get
    @redis.incr('audisa:discovery_id')
  end

end
