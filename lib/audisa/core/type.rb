class Core::Type

  def initialize(klass, name)
    @klass = klass
    @name = name
  end

  def eq? klass, name
    @klass == klass && @name == name
  end

  def is? klass
    @klass == klass
  end

  def of? name
    @name == name
  end

  def to_s
    "#{@klass}.#{@name}"
  end

end