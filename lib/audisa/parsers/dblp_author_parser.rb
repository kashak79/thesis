class Parsers::DblpAuthorParser < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    # get the links
    _in.get.scan(/href="([^"]*\.xml)"/).flatten.each do |url|
      out.push(:url => url)
    end
  end

end
