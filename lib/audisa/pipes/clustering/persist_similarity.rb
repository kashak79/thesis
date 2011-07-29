class Pipes::PersistSimilarity < Pipes::Pipe

  ALPHA = 1

  def initialize(graph)
    @graph = graph
    @locking = Helpers::Locker.new
    super()
  end

  # there is no need to lock the clusters for intra cluster addition
  # the clusters of the 2 instances will not change if the clusters
  # were not locked for the reclustering before (and this would trigger
  # the watches)

  # persisting a similarity is saving it
  def execute
    similarity = _in.get[:similarity]
    from   = similarity[:from]
    to     = similarity[:to]
    weight = similarity[:weight]

    # lock the 2 instances so that clusters are
    # not changed during the asking and watching/locking the clusters!
    @locking.lock(:instance, from, to)
    # now get cluster nodes
    fromcluster = @graph.out(:instance_of, from)
    tocluster   = @graph.out(:instance_of, to)
    # now start watching the clusters for lock changes
    # (when a reclustering begins) -> optimistic locking
    # will not occur alot
    # we do not take a lock ourselves because some similarity
    # processing can be done in parallel
    # if reclustering takes a lock, cancel transaction (later)
    if fromcluster[:_id] == tocluster[:_id]
      # intra-cluster similarity addition -> just watch the locks!
      $redis.watch(fromcluster)
      $redis.watch(tocluster)
      # now the instances can be unlocked (watching the clusters now)
      @locking.unlock(:instance, from, to)
      # do the processing
      intra_add(from, to, weight)
    else
      # inter-cluster similarity addition -> take locks on the clusters
      # nothing (similarity plane) in the clusters can change now!
      # (triggers watches of intra-cluster adds)
      $redis.lock(:cluster, fromcluster, tocluster)
      # now the instances can be unlocked (watching the clusters now)
      @locking.unlock(:instance, from, to)
      # do the processing
      inter_add(from, to, fromcluster, tocluster, weight)
    end
  end

  def intra_add(from, to, weight)
    puts "INTRA CLUSTER SIMILARITY"
    # update adjacency matrix
    $redis.incrby("A:#{from}:#{to}", weight)
    # update ICW and OCW
    $redis.incrby("icw:#{from}", weight)
    $redis.incrby("icw:#{to}", weight)
  end

  def inter_add(from, to, fromcluster, tocluster, weight)
    puts "INTER CLUSTER SIMILARITY"
    # get the size of the graph (family) |V|
    nV = @graph.query(fromcluster, @b.v.out(:author_of).in(:author_of).in(:instance_of).count()).first
    # calculate the cluster qualities
    # ids of the instances
    fromids = @graph.query(frocluster, @b.v.in(:instance_of)).map { |i| i[:_id] }
    toids   = @graph.query(tocluster, @b.v.in(:instance_of)).map { |i| i[:_id] }
    # calculate qualities
    fromquality = ($redis.mget(*fromids.map { |id| "ocw:#{id}" }) + weight)/(nV-ids.size)
    toquality   = ($redis.mget(*toids.map { |id| "ocw:#{id}" }) + weight)/(nV-ids.size)
    # check the quality
    if fromquality <= ALPHA && toquality <= ALPHA
      # we are in case 1, handle like an intra_cluster addition
      intra_add(from, to, weight)
    elsif 2*cut_value(fromids, toids)/nV >= ALPHA
      # we are in case 2, merge!
      # ....
    end
    # unlock the clusters
    @locking.unlock(:cluster, from, to)
  end

  def cut_value(ids1, ids2)
    # combinations
    $redis.mget(ids1.product(ids2).map { |pair| "A:#{pair[0]}:#{pair[1]}"}).sum
  end

end
