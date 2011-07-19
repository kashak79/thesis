class Pipes::Stdout < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    puts _in.get
    # push through
    out.push(_in.get)
  end

end
