class Helpers::Stdout < Core::Pipe

  def execute(*args)
    puts args
    # push through
    push(*args)
  end

end