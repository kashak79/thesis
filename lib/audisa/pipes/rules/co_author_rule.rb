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
      out.push(:similarity => {:from => similarity[:from1].to_i, :to => similarity[:to1].to_i, :weight => Configuration::COAUTHOR_EQNAME_WEIGHT, :type => "coauthor doubleeq"})
      out.push(:similarity => {:from => similarity[:from2].to_i, :to => similarity[:to2].to_i, :weight => Configuration::COAUTHOR_EQNAME_WEIGHT, :type => "coauthor doubleeq"})
    end if similarities # filter
    
    # double matching query
    query = @b.v.as('"\'from1\'"').match_inst.as('"\'to1\'"').except('[v]').co_inst.as('"\'from2\'"').match_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to2\'"').table(:id,:id,:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      out.push(:similarity => {:from => similarity[:from1].to_i, :to => similarity[:to1].to_i, :weight => Configuration::COAUTHOR_MATCHINGNAME_WEIGHT, :type => "coauthor doublematch"})
      out.push(:similarity => {:from => similarity[:from2].to_i, :to => similarity[:to2].to_i, :weight => Configuration::COAUTHOR_MATCHINGNAME_WEIGHT, :type => "coauthor doublematch"})
    end if similarities # filter

    # name-eq + matching query
    query = @b.v.as('"\'from1\'"').match_inst.as('"\'to1\'"').except('[v]').co_inst.as('"\'from2\'"').name_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to2\'"').table(:id,:id,:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      # co-author name equality
      out.push(:similarity => {:from => similarity[:from1].to_i, :to => similarity[:to1].to_i, :weight => Configuration::COAUTHOR_EQNAME_WEIGHT, :type => "coauthor name-eq+match"})
      # co-author match equality, ook 1?
      out.push(:similarity => {:from => similarity[:from2].to_i, :to => similarity[:to2].to_i, :weight => Configuration::COAUTHOR_MATCHINGNAME_WEIGHT, :type => "coauthor name-match+eq"})
    end if similarities # filter
    
    # name-eq + matching query (inverted)
    query = @b.v.as('"\'from1\'"').name_inst.as('"\'to1\'"').except('[v]').co_inst.as('"\'from2\'"').match_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to2\'"').table(:id,:id,:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      # co-author name equality
      out.push(:similarity => {:from => similarity[:from1].to_i, :to => similarity[:to1].to_i, :weight => Configuration::COAUTHOR_MATCHINGNAME_WEIGHT, :type => "coauthor name-match+eq"})
      # co-author match equality, ook 1?
      out.push(:similarity => {:from => similarity[:from2].to_i, :to => similarity[:to2].to_i, :weight => Configuration::COAUTHOR_EQNAME_WEIGHT, :type => "coauthor name-match+eq"})
    end if similarities # filter
  end

end
