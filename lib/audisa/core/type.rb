class Core::Type

  def initialize(klass, name)
    @klass = klass
    @name = name
  end

  def is? klass
    @klass == klass
  end

  def instantiate(properties)
    @klass.new(@name, properties)
  end

  def to_s
    "#{@klass}.#{@name}"
  end

end