class Pipes::PersistFact < Pipes::Pipe

  def initialize(graph, from, to, label)
    super()
    @graph = graph
    @from = from
    @to = to
    @label = label
  end

  def execute
    froms = [(_in.get[@from] || [])].flatten
    tos = [(_in.get[@to] || [])].flatten
    froms.each do |from|
      tos.each do |to|
        @graph.create_edge(@label, from[:_id], to[:_id])
      end
    end
    
    enrich(:in, :out, {})
  end

end
