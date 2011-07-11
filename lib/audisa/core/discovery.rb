class Core::Discovery
  PUBLICATION = Core::Type.new(Core::Discovery, :publication)

  def initialize(type, properties)
    @type = type
    @properties = properties
  end

end
