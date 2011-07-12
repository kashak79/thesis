class Pipes::Filter < Core::Pipe

  def initialize(&filter)
    super()
    @filter = filter
  end

  def execute(*args)
    push(*args) if @filter.call(*args)
  end

end
