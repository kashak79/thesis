class Helpers::Locker
  TIMEOUT = 10
  MAX_ATTEMPTS = 100

  def lock(entity)
    #puts "locking #{entity}"
    $redis.lock(entity)
    yield
    #puts "unlocking #{entity}"
    $redis.unlock(entity)
  end

end
