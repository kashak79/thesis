class Connections::Local < Connections::Connection
  # push data in the connection (stateful)
  def push(data)
    @data = data
    touch
  end

  # get the data in the connection
  def get
    @data
  end
end