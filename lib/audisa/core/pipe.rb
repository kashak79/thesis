class Core::Pipe
  @queue = :test
  @@repo = Core::Repository.new

  def initialize(name = nil)
    @chains = []
    @name = name
  end

  def self.define(name)
    @@repo.store(name, yield(Core::Pipe.new(name)))
  end

  def self.[](name)
    @@repo[name]
  end

  def push(*output)
    # propagate
    @chains.each do |chain|
      chain.execute(*output)
    end
  end

  def chain_pure(pipe_klass, *args)
    pipe = pipe_klass.new(*args)
    @chains << pipe
    pipe
  end

  def chain(pipe_klass, *args)
    Core::Pipeline.new(self, chain_pure(pipe_klass, *args))
  end

  ## ASYNC
  # Performing is executing a named pipe(line)
  def self.perform(name, *args)
    self[name.to_sym].push(*args)
  end

  # Executing asynchronously is the same as scheduling it in Resque
  def async_push(*args)
    Resque.enqueue(self.class, @name, *args)
  end

end
