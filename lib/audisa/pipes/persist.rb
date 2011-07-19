class Pipes::Persist < Pipes::Pipe

  def initialize(uri)
    super()
    @uri = uri
  end

  def execute
    response = Typhoeus::Request.post("#{@uri}/vertices/#{_in.get[:id]}",
      :params => _in.get.reject { |k,v| k == :id }
    )
    # push through
    out.push(_in.get)
  end

end
