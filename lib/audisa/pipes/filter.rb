class Pipes::Filter < Pipes::Pipe

  def initialize(filter)
    super([:in], [true,false])
    @filter = filter
  end

  def execute
    filtered = @filter.call(_in.get)
    if filtered
      out(true).push(filtered) # also filtering on the incoming data
    else
      out(false).push(_in.get)
    end
  end

end
