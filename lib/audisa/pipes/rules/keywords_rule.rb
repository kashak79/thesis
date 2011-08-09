class Pipes::KeywordsRule < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    query = @b.v.out('"published"').out('"keyword"').in('"keyword"').except(@b.v.out('"published"').to_a).in('"published"')
    keyword_instances = @graph.query(instance[:_id], query)
    keyword_instances.each do |keyword_instance|
			# p "found keyword equality between #{instance[:_id]} and #{keyword_instance[:_id]}" #if Configuration::DEBUG
      out.push(:similarity => {:from => instance[:_id], :to => keyword_instance[:_id], :weight => Configuration::KEYWORD_WEIGHT, :type => "keyword equality"})
    end if keyword_instances # filter
  end
end
