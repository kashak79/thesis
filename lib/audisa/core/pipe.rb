class Core::Pipe

  def initialize
    @chains = []
    yield self if block_given?
  end

  def execute(*args)
    push(*args)
  end

  def push(*output)
    # propagate
    @chains.each do |chain|
      chain.execute(*output)
    end
  end

  def chain(pipe)
    @chains << pipe
    pipe
  end

end
