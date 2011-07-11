class Helpers::SimpleIdProvider

  def initialize
    @id = 0
  end

  def get
    @id+=1
  end

end
