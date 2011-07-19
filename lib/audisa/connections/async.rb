class Connections::Async < Connections::Connection
  class << self
    attr_accessor :data, :to
  end

  # initializing an async connection means making a new class!
  def initialize(name, queue)
    @queue = queue
    name = name.to_s.capitalize
    klass = Class.new Connections::Async
    Connections.const_set name, klass
    @klass = eval("Connections::#{name}")
  end

  def to(pipe, name = :in)
    super(pipe, name)
    # to pipe is established, get it into the runtime class
    @klass.to = @to
    pipe
  end

  # push data into the connection
  # here this means, make a resque task
  def push(data)
    Resque.push(@queue, :class => @klass, :args => [data])
  end

  # later resque will call perform
  # this means the pipe continues in another process,
  # make the data stateful now (over the entire class)
  def self.perform(data)
    self.data = data
    self.to.touch
  end

  # get the data in the connection
  def get
    @klass.data
  end
end
