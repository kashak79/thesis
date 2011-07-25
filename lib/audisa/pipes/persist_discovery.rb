class Pipes::PersistDiscovery < Pipes::Pipe

  def initialize(graph, entity)
    super()
    @graph = graph
    @entity = entity
  end

  def execute
    publication = @graph.create_vertex(_in.get[@entity])
    enrich(:in, :out, :publication => publication)
  end

end
