class Pipes::Bind < Core::Pipe

  def initialize(to)
    super()
    @to = to
  end

  def execute(*args)
    next_pipe = Core::Pipe[@to]
    next_pipe.push(*args)
  end

end
