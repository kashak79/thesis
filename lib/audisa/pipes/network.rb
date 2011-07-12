class Pipes::Network < Core::Pipe

  def execute(url, options = {})
    response = Typhoeus::Request.get(url, options)
    push(response.body)
  end

end
