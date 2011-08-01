class Helpers::Locker
  TIMEOUT = 10
  MAX_ATTEMPTS = 100

  def locked(entity)
    #puts "locking #{entity}"
    $redis.lock(entity)
    yield
    #puts "unlocking #{entity}"
    $redis.unlock(entity)
  end

  def lock(type, *entities)
    entities.each do |entity|
      $redis.lock("#{type}:#{entity}")
      puts "locked #{type}:#{entity}"
    end
  end

  def unlock(type, *entities)
    entities.each do |entity|
      $redis.unlock("#{type}:#{entity}")
      puts "unlocked #{type}:#{entity}"
    end
  end

end
