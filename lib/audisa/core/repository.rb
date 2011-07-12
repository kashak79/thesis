class Core::Repository

  def initialize
    @items = {}
  end

  def store(name, item)
    @items[name] = item
    # protect
    item
  end

  def get(name)
    @items[name]
  end

  def [](name)
    @items[name]
  end

end
