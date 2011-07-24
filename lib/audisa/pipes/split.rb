class Pipes::Split < Pipes::Pipe
  def initialize(n)
    out = []
    n.times do |i|
      out << (i+1)
    end
    super([:in], out)
  end

  def execute
    outs.each do |name,out|
      out.push(_in.get)
    end
  end
end
