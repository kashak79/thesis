class Helpers::Locker
  TIMEOUT = 10
  MAX_ATTEMPTS = 100

  def locked(entity)
    #puts "locking #{entity}"
    #$redis.lock(entity)
    yield
    #puts "unlocking #{entity}"
    #$redis.unlock(entity)
  end

  def lock(type, *entities)
    #$redis.multi do
    #  entities.each do |entity|
    #    $redis.lock("#{type}:#{entity}")
    #  end
    #end
  end

  def unlock(type, *entities)
    #$redis.multi do
    #  entities.each do |entity|
    #    $redis.unlock("#{type}:#{entity}")
    #  end
    #end
  end

end
