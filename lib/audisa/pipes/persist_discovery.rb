class Pipes::PersistDiscovery < Pipes::Pipe

  def initialize(graph, entity, options = {})
    super()
    @graph = graph
    @entity = entity
    @index = options[:index] || false
  end

  def execute
    discoveries = [_in.get[@entity] || []].flatten

    discoveries = discoveries.map do |discovery|
      index = @graph.index(@entity, discovery[@index]).first if @index
      if !index
        discovery = @graph.create_vertex(discovery)
        @graph.put_index(@entity, discovery[@index]) if @index
      end
      index || discovery
    end

    discoveries = discoveries.size == 1 ? discoveries.first : discoveries
    
    enrich(:in, :out, ((discoveries.empty?) ? {} : {@entity => discoveries}))
  end

end
