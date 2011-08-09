class Pipes::AffiliationRule < Pipes::Pipe

  def initialize(graph, matcher)
    super()
    @graph = graph
		@matcher = matcher
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    affiliation = _in.get[:affiliation]
    query = @b.v.match_inst.except('[v]').as('"\'instance\'"').out('"affiliation"').as('"\'affiliation\'"').table(:id, :affiliation)
		query2 = @b.v.name_inst.except('[v]').as('"\'instance\'"').out('"affiliation"').as('"\'affiliation\'"').table(:id, :affiliation)
    pairs = (@graph.table(instance[:_id], query) || []) + (@graph.table(instance[:_id], query2) || [])
    pairs.each do |pair|
      affiliation_match = pair[:affiliation]
      instance_match = pair[:instance].to_i
      # vergelijk affiliation & affiliation match
      # indien gelijkaardig push similarity tussen instance & instance_match
			probability = @matcher.match(affiliation[:affiliation], affiliation_match)
			# p "######################## Probability is #{probability} between #{affiliation_match} and #{instance}"
      out.push(:similarity => {:from => instance[:_id], :to => instance_match, :weight => Configuration::AFFILIATION_WEIGHT, :type => "affiliation match"}) if probability >= Configuration::AFFILIATION_THRESHOLD
    end if pairs && affiliation # filter
  end

end
