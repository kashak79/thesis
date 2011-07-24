class Pipes::Pipe
  attr_accessor :touched

  # initialize pipe
  def initialize(inbound = [:in], outbound = [:out])
    # map of named inbound connectors
    @in = {}
    inbound.each { |name| @in[name] = Connections::Connector.new(self) }
    # map of named outbound connectors
    @out = {}
    outbound.each { |name| @out[name] = Connections::Connector.new(self) }
  end

  # select an inbound connector
  def in(name = :in)
    @in[name]
  end
  alias_method :_in, :in

  # select an outbound connector
  def out(name = :out)
    @out[name]
  end

  # get all outbound connectors
  def outs
    @out
  end

  # get all inbound connectors
  def ins
    @ins
  end

  # enrich the input and push
  def enrich(inbound, outbound, data)
    out(outbound).push(self.in(inbound).get.merge(data))
  end

  # fallback
  def pipe(*args)
    self
  end

  # pipe piece construction method
  def self.pipe(*args)
    # just initialize the pipe
    pipe = self.new(*args)
    # execute block if necessary
    yield(pipe) if block_given?
    pipe
  end
end