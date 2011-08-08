class Pipes::AffiliationRule < Pipes::Pipe

  def initialize(graph, matcher)
    super()
    @graph = graph
		@matcher = matcher
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    p affiliation = _in.get[:affiliation] # ja?
    query = @b.v.match_inst.as('"\'instance\'"').out('"affiliation"').as('"\'affiliation\'"')
		query2 = @b.v.name_inst.as('"\'instance\'"').out('"affiliation"').as('"\'affiliation\'"')
    p pairs = @graph.table(instance[:_id], query) + @graph.table(instance[:_id], query2)
    pairs.each do |pair|
      affiliation_match = pair[:affiliation]
      instance_match = pair[:instance]
      # vergelijk affiliation & affiliation match
      # indien gelijkaardig push similarity tussen instance & instance_match
			probability = @matcher.match(affiliation, affiliation_match)
			p "######################## Probability is #{probability} between #{affiliation_match} and #{instance_match}"
      out.push(:similarity => {:from => similarity[:instance], :to => similarity[:affiliation], :weight => Configuration::AFFILIATION_WEIGHT, :type => "affiliation match"}) if probability >= Configuration::AFFILIATION
    end if pairs # filter
  end

end
