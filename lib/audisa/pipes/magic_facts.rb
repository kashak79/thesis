class Pipes::MagicFacts < Pipes::Pipe

  def initialize(source)
    super()
    @facts = Yajl::Parser.parse(source)
  end

  def execute
    publication = _in.get
  end

end