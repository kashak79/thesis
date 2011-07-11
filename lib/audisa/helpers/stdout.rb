class Helpers::Stdout < Core::Pipe

  def execute(*args)
    puts args
  end

end