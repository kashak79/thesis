class Pipes::Persistor < Core::Pipe

  def initialize(uri)
    super()
    @uri = uri
  end

  def execute(type, properties)
    if type.is? Core::Discovery
      response = Typhoeus::Request.post("#{@uri}/vertices/#{properties[:id]}",
        :params => properties.reject { |k,v| k == :id }
      )
    end
    push(type, properties)
  end

end
