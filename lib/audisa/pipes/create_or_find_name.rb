class Pipes::CreateOrFindName < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    # name parts
    parts = _in.get[:name].split(' ')
    family = parts.last
    name = parts[0..-2] * ' '
    # search for name node in the index
    name_node = @graph.index(:name, name)
    # create structure if name node does not exist yet
    name_node = create_name(name, family) if !name_node

  end

end
