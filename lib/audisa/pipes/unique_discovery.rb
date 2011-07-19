class Pipes::UniqueDiscovery < Pipes::Pipe

  def initialize(id_provider)
    super()
    @id_provider = id_provider
  end

  # assign a unique id to every discovery
  def execute
    out.push(_in.get.merge(:id => @id_provider.get))
  end

end
