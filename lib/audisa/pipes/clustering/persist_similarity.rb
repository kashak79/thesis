class Pipes::PersistSimilarity < Pipes::Pipe

  ALPHA = 0.1

  def initialize(graph)
    @graph = graph
    @locking = Helpers::Locker.new
    @b = Helpers::QueryBuilder.new
    super()
  end

  # there is no need to lock the clusters for intra cluster addition
  # the clusters of the 2 instances will not change if the clusters
  # were not locked for the reclustering before (and this would trigger
  # the watches)

  # persisting a similarity is saving it
  def execute
    similarity = _in.get[:similarity]
    p similarity
    from   = similarity[:from]
    to     = similarity[:to]
    weight = similarity[:weight]

    p @graph.query(from, @b.v.out('"published"')).first[:title]
    p @graph.query(from, @b.v).first[:name]
    p @graph.query(to, @b.v.out('"published"')).first[:title]
    p @graph.query(to, @b.v).first[:name]

    # lock the 2 instances so that clusters are
    # not changed during the asking and watching/locking the clusters!
    @locking.lock(:instance, from, to)
    # now get cluster nodes
    fromcluster = @graph.out(:instance_of, from).first[:_inV]
    tocluster   = @graph.out(:instance_of, to).first[:_inV]
    p fromcluster
    p tocluster
    # now start watching the clusters for lock changes
    # (when a reclustering begins) -> optimistic locking
    # will not occur alot
    # we do not take a lock ourselves because some similarity
    # processing can be done in parallel
    # if reclustering takes a lock, cancel transaction (later)
    if fromcluster == tocluster
      puts "INTRA CLUSTER SIMILARITY"
      # intra-cluster similarity addition -> just watch the locks!
      $redis.watch(fromcluster)
      $redis.watch(tocluster)
      # now the instances can be unlocked (watching the clusters now)
      @locking.unlock(:instance, from, to)
      # do the processing
      intra_add(from, to, weight)
    else
      puts "INTER CLUSTER SIMILARITY"
      # inter-cluster similarity addition -> take locks on the clusters
      # nothing (similarity plane) in the clusters can change now!
      # (triggers watches of intra-cluster adds)
      @locking.lock(:cluster, fromcluster, tocluster)
      # now the instances can be unlocked (watching the clusters now)
      @locking.unlock(:instance, from, to)
      # do the processing
      inter_add(from, to, fromcluster, tocluster, weight)
    end
  end

  def intra_add(from, to, weight)
    # update adjacency matrix
    $redis.incrby("A:#{from}:#{to}", weight)
    # update ICW and OCW
    $redis.incrby("icw:#{from}", weight)
    $redis.incrby("icw:#{to}", weight)
  end

  def inter_add(from, to, fromcluster, tocluster, weight)
    # get the size of the graph (family) |V|
    nV = @graph.query(fromcluster, @b.v.out('"author_of"').in('"author_of"').in('"instance_of"').count()).first
    p "|V|=#{nV}"
    # calculate the cluster qualities
    # ids of the instances
    fromids = @graph.query(fromcluster, @b.v.in('"instance_of"')).map { |i| i[:_id] }
    toids   = @graph.query(tocluster, @b.v.in('"instance_of"')).map { |i| i[:_id] }
    p fromids
    p toids
    # calculate qualities
    fromquality = (($redis.mget(*fromids.map { |id| "ocw:#{id}" })).inject(0) { |n,i|
      n+(i.to_i||0)
    }+weight).to_f/(nV-fromids.size)
    toquality   = (($redis.mget(*toids.map { |id| "ocw:#{id}" })).inject(0) { |n,i|
      n+(i.to_i||0)
    }+weight).to_f/(nV-toids.size)
    p fromquality
    p toquality
    puts "cutvalue #{cut_value(fromids, toids)}"
    # check the quality
    if fromquality <= ALPHA && toquality <= ALPHA
      # we are in case 1, handle like an intra_cluster addition
      puts "CASE 1"
      intra_add(from, to, weight)
    elsif 2*(cut_value(fromids, toids)+weight).to_f/nV >= ALPHA
      puts "CASE 2"
      intra_add(from, to, weight) # JA?
      merge(fromids, fromcluster, toids, tocluster)
    else
      puts "CASE 3 ############################################"
    end
    # unlock the clusters
    @locking.unlock(:cluster, fromcluster, tocluster)
  end

  def merge(ids1, cluster1, ids2, cluster2)
    # relocate edges
    puts "relocating"
    puts "instances"
    p @graph.query(cluster2, @b.v.in('"instance_of"'))
    @graph.query(cluster2, @b.v.in('"instance_of"')).each do |instance|
      @graph.create_edge(:instance_of, instance[:_id], cluster1)
    end

    @graph.in(:instance_of, cluster2).each do |edge|
      @graph.delete_edge(edge[:_id])
    end
    puts "deleting cluster"
    #@graph.delete_vertex(cluster2)
    puts "relocated"
    # update icw/ocw
    ids1.each do |fid|
      total = weights(ids2.map { |tid| [fid,tid] })
      $redis.incrby("icw:#{fid}", total)
      $redis.decrby("ocw:#{fid}", total)
    end
    ids2.each do |tid|
      total = weights(ids1.map { |fid| [fid,tid] })
      $redis.incrby("icw:#{tid}", total)
      $redis.decrby("ocw:#{tid}", total)
    end
    puts "merged"
    #STDIN.gets
  end

  def cut_value(ids1, ids2)
    # combinations
    weights(ids1.product(ids2))
  end

  def weights(pairs)
    $redis.mget(pairs.map { |pair|
      ["A:#{pair[0]}:#{pair[1]}", "A:#{pair[1]}:#{pair[0]}"] # both sides
    }.flatten).inject(0) { |n,i|
      n+(i.to_i||0)
    }
  end

end
