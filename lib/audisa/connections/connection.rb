class Connections::Connection
  # connect the connection to a receiving connector (name)
  # return the pipe
  def to(pipe, name = :in)
    pipe = pipe.pipe
    @to = pipe.in(name)
    @to.connect(self)
    yield(pipe) if block_given?
    pipe
  end

  # notify the connector
  def touch
    @to.touch
  end

  # fallback if instance already constructed
  def connection(*args)
    self
  end

  # connection construction method
  def self.connection(*args)
    # just initialize the connection
    self.new(*args)
  end
end
