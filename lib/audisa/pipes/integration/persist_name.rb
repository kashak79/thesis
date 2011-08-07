class Pipes::PersistName < Pipes::Pipe

  def initialize(graph)
    @graph = graph
    @locking = Helpers::Locker.new
    super([:in], [:exist, :new])
  end

  def execute
    dyn_out = :exist
    # get the instance and family
    instance = _in.get[:instance]
    family = _in.get[:family]
    # split the name
    name_parts = instance[:name].split ' '
    first_name = name_parts[0..-2] * ' '
    # avoid double names
    name = nil
    @locking.locked("instance:#{instance[:_id]}") do
      # does the name exist?
      name = @graph.index(:name, instance[:name]).first
      if !name
        dyn_out = :new
        # create the name
        name = @graph.create_vertex(:name => instance[:name])
        # put in the index
        @graph.put_index(:name, name[:name], name[:_id])
        # connect
        @graph.create_edge(:family, name[:_id], family[:_id])
      end
    end
    # connect
    @graph.create_edge(:name, instance[:_id], name[:_id])
    # enrich
    enrich(:in, dyn_out, :name => name)
  end

end
