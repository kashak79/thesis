class Pipes::KeywordsRule < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    query = @b.v.out('"published"').out('"keyword"').as('"\'keyword\'"').in('"keyword"').except(@b.v.out('"published"').to_a).in('"published"').retain(@b.v.name_inst.to_a).as('"\'instance\'"').table(:keyword, :id)
    keyword_instances = @graph.table(instance[:_id], query)
    keyword_instances.each do |keyword_instance|
      keyword = keyword_instance[:keyword]
      words = keyword.split(' ').size
      kinstance = keyword_instance[:instance]
      puts "###############"
      p keyword if words > 1
			# p "found keyword equality between #{instance[:_id]} and #{keyword_instance[:_id]}" #if Configuration::DEBUG
			#p instance[:_id]
			#p kinstance
			#p Configuration::KEYWORD_WEIGHT*(words**4)
			$redis.incrby("stat:keywordweight", Configuration::KEYWORD_WEIGHT*(words**4))
      out.push(:similarity => {:from => instance[:_id], :to => kinstance.to_i, :weight => Configuration::KEYWORD_WEIGHT*(words**4), :type => "keyword equality"})
    end if keyword_instances # filter
  end
end
