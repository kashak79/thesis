class Core::Pipeline

  def initialize(first, last)
    @first = first
    @last = last
  end

  def push(*args)
    @first.push(*args)
  end

  def async_push(*args)
    @first.async_push(*args)
  end

  def chain(pipe, *args)
    @last = @last.chain_pure(pipe, *args)
    # return the pipeline
    self
  end

  def filter(&block)
    @last = @last.filter_pure(&block)
    self
  end

end