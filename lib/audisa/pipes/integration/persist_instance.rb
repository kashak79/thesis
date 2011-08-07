class Pipes::PersistInstance < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
  end

  def execute
    # get the instance properties
    instance_properties = _in.get[:instance]
    # first create the instance
    instance = @graph.create_vertex(instance_properties)
    # every new instance is created in a new cluster
    # a cluster is an author
    # in this case with the same name as the instance
    author = @graph.create_vertex({}) # name?
    # connect the instance with the author (-> cluster of size 1)
    @graph.create_edge(:instance_of, instance[:_id], author[:_id])
    # replace the instance by the persisted one in the flow
    # and push!
    enrich(:in, :out, :instance => instance, :author => author)
  end

end
