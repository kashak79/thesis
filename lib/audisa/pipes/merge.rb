class Pipes::Merge < Pipes::Pipe
  def initialize(n)
    _in = []
    n.times do |i|
      _in << (i+1)
    end
    super(_in, [:out])
  end

  def execute
    out.push(touched.get)
  end
end
