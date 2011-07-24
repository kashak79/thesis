class Pipes::NameMatching < Pipes::Pipe

  def initialize(graph, matcher, treshold)
    @graph = graph
    @matcher = matcher
    @treshold = treshold
    super()
  end

  # goal: find all names in a family (except own name)
  # and try to match them with the name in this context
  # if the match-distance exceeds a certain treshold,
  # then persist a relation that allows rules to do
  # inter-name matching later on
  def execute
    # get the family and name
    family = _in.get[:family]
    name = _in.get[:name]
    # issue the query in the family context
    possible_names = @graph.query(name[:_id], "v.out('family').in('family').except([v])")
    # execute matching algorithm for each of these names
    possible_names.each do |possible_name|
      probability = @matcher.match(name[:name], possible_name[:name])
      persist_matching(name, possible_name) if probability <= @treshold
    end
    enrich(:in, :out, {})
  end

  def persist_matching(name, matching_name)
    @graph.create_edge(:matches, name[:_id], matching_name[:_id])
  end

end
