class Pipes::Network < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    response = Typhoeus::Request.get(_in.get[:url])
    out.push(response.body)
  end

end
