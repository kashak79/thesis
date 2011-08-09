class Pipes::PersistSimilarity < Pipes::Pipe

  CLUSTERING = File.expand_path("clustering")

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
    # lock the 2 instances so that clusters are
    # not changed during the asking and watching/locking the clusters!
    @locking.lock(:graph, 1)
    #@locking.lock(:instance, from, to)
    # now get cluster nodes
    fromcluster = @graph.out(:instance_of, from).first[:_inV]
    tocluster   = @graph.out(:instance_of, to).first[:_inV]
    # now start watching the clusters for lock changes
    # (when a reclustering begins) -> optimistic locking
    # will not occur alot
    # we do not take a lock ourselves because some similarity
    # processing can be done in parallel
    # if reclustering takes a lock, cancel transaction (later)
    if fromcluster == tocluster
      puts "INTRA CLUSTER SIMILARITY"
      # intra-cluster similarity addition -> just watch the locks!
      # $redis.watch("lock:cluster#{fromcluster}")
      # $redis.watch("lock:cluster#{tocluster}")
      # $redis.lock(:cluster, fromcluster, tocluster)
      # now the instances can be unlocked (watching the clusters now)
      # do the processing
      $redis.multi do
        # update adjacency matrix
        $redis.incrby(a(from, to), weight)
        # update ICW and OCW
        $redis.incrby("icw:#{from}", weight)
        $redis.incrby("icw:#{to}", weight)
      end
      # $redis.unlock(:cluster, fromcluster, tocluster)
      #@locking.unlock(:instance, from, to)
    else
      puts "INTER CLUSTER SIMILARITY"
      # inter-cluster similarity addition -> take locks on the clusters
      # nothing (similarity plane) in the clusters can change now!
      # (triggers watches of intra-cluster adds)
      #@locking.unlock(:instance, from, to)
      #@locking.lock(:cluster, fromcluster, tocluster)
      # now the instances can be unlocked (watching the clusters now)
      # @locking.unlock(:instance, from, to)
      # do the processing
      inter_add(from, to, fromcluster, tocluster, weight)
      #@locking.unlock(:cluster, fromcluster, tocluster)
    end
    @locking.unlock(:graph, 1)
  end

  def inter_add(from, to, fromcluster, tocluster, weight)
    # get the size of the graph (family) |V|
    nV = @graph.query(fromcluster, @b.v.out('"author_of"').in('"author_of"').in('"instance_of"').count()).first
    # calculate the cluster qualities
    # ids of the instances
    query = @b.v.in('"instance_of"')
    fromids = @graph.query(fromcluster, query).map { |i| i[:_id] }
    toids   = @graph.query(tocluster, query).map { |i| i[:_id] }
    # lock all the instances
    #@locking.lock(:instance, fromids+toids)
    # calculate qualities
    fromquality = (sum(fromids) { |id| "ocw:#{id}" }+weight).to_f/(nV-fromids.size)
    toquality   = (sum(fromids) { |id| "icw:#{id}" }+weight).to_f/(nV-toids.size)
    # check the quality
    if fromquality <= Configuration::ALPHA && toquality <= Configuration::ALPHA
      puts "CASE 1"
      $redis.incrby(a(from, to), weight)
      # update ICW and OCW
      $redis.incrby("ocw:#{from}", weight)
      $redis.incrby("ocw:#{to}", weight)
      
    elsif 2*(cut_value(fromids, toids)+weight).to_f/nV >= Configuration::ALPHA
      puts "CASE 2"
      $redis.multi do
        # update adjacency matrix
        $redis.incrby(a(from, to), weight)
        # update OCW
        $redis.incrby("ocw:#{from}", weight)
        $redis.incrby("ocw:#{to}", weight)
      end
      merge(fromids, fromcluster, toids, tocluster)
    else
      $redis.multi do
        # update adjacency matrix
        $redis.incrby(a(from, to), weight)
        # update OCW
        $redis.incrby("ocw:#{from}", weight)
        $redis.incrby("ocw:#{to}", weight)
      end
      #puts "CASE 3 ############################################"
      #deps = ["blueprints-core-0.8.jar","commons-pool-1.5.6.jar","gson-1.7.1.jar","jedis-2.0.0.jar","jung-3d-2.0.1.jar","jung-algorithms-2.0.1.jar","jung-graph-impl-2.0.1.jar"]
      #cp = deps.map { |dep| "#{CLUSTERING}/lib/#{dep}"} * ':'
      #p "java -cp #{cp};#{CLUSTERING}/bin clustering.CaseThree #{fromids} #{toids} #{nV} #{Configuration::ALPHA}"
      #result = `java -cp #{cp}:#{CLUSTERING}/bin clustering.CaseThree #{Yajl::Encoder.encode(fromids)} #{Yajl::Encoder.encode(toids)} #{nV} #{Configuration::ALPHA}`
      #result = Yajl::Parser.parse(result)
      #relocate(fromids+toids, [fromcluster, tocluster], result)
    end
    # lock all the instances
    #@locking.unlock(:instance, fromids+toids)
  end

  def merge(ids1, cluster1, ids2, cluster2)
  # relocate edges
    ids2.each do |id|
      @graph.create_edge(:instance_of, id, cluster1)
    end
    # delete edges / cluster
    @graph.in(:instance_of, cluster2).each do |edge|
      @graph.delete_edge(edge[:_id])
    end
    @graph.delete_vertex(cluster2)
    # update icw/ocw
    ids1.each do |fid|
      total = sum(ids2.map { |tid| [fid,tid] }) { |pair| a(*pair) }
      $redis.incrby("icw:#{fid}", total)
      $redis.decrby("ocw:#{fid}", total)
    end 
    ids2.each do |tid|
      total = sum(ids1.map { |fid| [fid,tid] }) { |pair| a(*pair) }
      $redis.incrby("icw:#{tid}", total)
      $redis.decrby("ocw:#{tid}", total)
    end
  end
  
  def relocate(ids, clusters, toclusters)
    # get the family
    family = @graph.query(clusters.first, @b.v.out('"author_of"')).first[:_id]
    # delete all instance of edges
    clusters.each do |c|
      @graph.in(:instance_of, c).each do |edge|
        @graph.delete_edge(edge[:_id])
      end
    end
    # first make new clusters if necessary
    (toclusters.size-2).times do
      clusters << new_cluster(family)
    end
    # now relocate every instance
    ids.each do |id|
      cluster_index = toclusters.index { |c| c.include? id }
      cluster = clusters[cluster_index]
      @graph.create_edge(:instance_of, id, cluster)
    end
  end
  
  def new_cluster(family)
    author = @graph.create_vertex({})[:_id]
    @graph.create_edge(:author_of, author, family)
    author
  end

  def cut_value(ids1, ids2)
    # combinations
    sum(ids1.product(ids2)) { |pair| a(*pair) }
  end

  def sum(parts)
    $redis.mget(*parts.map { |part| yield(part) }).inject(0) { |n,i|
      n+(i.to_i||0)
    }
  end

  def a(id1, id2)
    (id1 < id2) ? "A:#{id1}:#{id2}" : "A:#{id2}:#{id1}"
  end

end
