class Pipes::CoAuthorRule < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    # double name-equality query
    query = @b.v.as('"\'from1\'"').name_inst.as('"\'to1\'"').except('[v]').co_inst.as('"\'from2\'"').name_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to2\'"').table(:id,:id,:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      out.push(:similarity => {:from => similarity[:from1], :to => similarity[:to1], :weight => 1, :type => "coauthor name-eq"})
      out.push(:similarity => {:from => similarity[:from2], :to => similarity[:to2], :weight => 1, :type => "coauthor name-eq"})
    end if similarities # filter

    # name-eq + matching query
    query = @b.v.as('"\'from1\'"').match_inst.as('"\'to1\'"').except('[v]').co_inst.as('"\'from2\'"').name_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to2\'"').table(:id,:id,:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      # co-author name equality
      out.push(:similarity => {:from => similarity[:from1], :to => similarity[:to1], :weight => 1, :type => "coauthor name-eq+match"})
      # co-author match equality, ook 1?
      out.push(:similarity => {:from => similarity[:from2], :to => similarity[:to2], :weight => 1, :type => "coauthor name-eq+match"})
    end if similarities # filter
  end

end
