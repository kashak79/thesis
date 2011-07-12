class Core::Discovery
  PUBLICATION = Core::Type.new(Core::Discovery, :publication)
  INSTANCE    = Core::Type.new(Core::Discovery, :instance)

  def initialize(type, properties)
    @type = type
    @properties = properties
  end

end
