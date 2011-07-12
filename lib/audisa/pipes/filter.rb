class Pipes::Filter < Core::Pipe

  def initialize(&filter)
    super()
    @filter = filter
  end

  def execute(*args)
    filtered = @filter.call(*args)
    filtered_data = filtered.kind_of?(Array) ? filtered : [filtered]
    push(*filtered_data) if filtered
  end

end
