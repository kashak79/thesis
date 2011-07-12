class Core::Pipe
  class << self
    attr_accessor :pipes
  end

  @queue = :test

  def initialize(name = nil)
    @chains = []
    @name = name
    yield self if block_given?
  end

  def self.define(name)
    self.pipes ||= {}
    pipe = self.new(name)
    yield(pipe)
    self.pipes[name] = pipe
  end

  def self.get(name)
    self.pipes[name]
  end

  # resque
  def self.perform(name, *args)
    p self.pipes
    p name
    self.get(name.to_sym).execute(*args)
  end

  def execute(*args)
    push(*args)
  end

  def async_execute(*args)
    Resque.enqueue(self.class, @name, *args)
  end

  def push(*output)
    # propagate
    @chains.each do |chain|
      chain.execute(*output)
    end
  end

  def chain(pipe, *args)
    pipe = pipe.new(*args)
    @chains << pipe
    pipe
  end

end
