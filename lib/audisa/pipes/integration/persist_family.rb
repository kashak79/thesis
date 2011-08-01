class Pipes::PersistFamily < Pipes::Pipe

  def initialize(graph)
    @graph = graph
    @locking = Helpers::Locker.new
    super([:in], [:exist, :new])
  end

  def execute
    dyn_out = :exist
    # get the instance
    instance = _in.get[:instance]
    author = _in.get[:author]
    # split the name
    name_parts = instance[:name].split ' '
    family_name = name_parts.last
    # first lock to avoid creating 2 equal families
    family = nil
    @locking.locked(family_name) do
      # does the family exist?
      family = @graph.index(:family, family_name).first
      if !family
        dyn_out = :new
        # create the family
        family = @graph.create_vertex(:family => family_name)
        # put in the index
        @graph.put_index(:family, family_name, family[:_id])
      end
    end
    # connect
    @graph.create_edge(:author_of, author[:_id], family[:_id])
    # enrich the input with the family
    enrich(:in, dyn_out, :family => family)
  end

end
