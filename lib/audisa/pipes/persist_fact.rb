class Pipes::PersistFact < Pipes::Pipe

  def initialize(graph, from, to, label)
    super()
    @graph = graph
    @from = from
    @to = to
    @label = label
  end

  def execute
    @graph.create_edge(@label, _in.get[@from][:_id], _in.get[@to][:_id])
    enrich(:in, :out, {})
  end

end
