class Pipes::UniqueDiscovery < Core::Pipe

  def initialize(id_provider)
    super()
    @id_provider = id_provider
  end

  # assign a unique id to every discovery
  def execute(type, properties)
    properties[:id] = @id_provider.get if type.is? Core::Discovery
    push(type, properties)
  end

end
