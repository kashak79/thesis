class Connections::Connector
  attr_accessor :connection

  # initilize with the pipe the connection belongs to
  def initialize(pipe)
    @pipe = pipe
  end
  # connecting this connector with a connection
  # return the connection
  def connect(connection = Connections::Local)
    @connection = connection.connection
  end

  # push data in the connector
  def push(data)
    @connection.push(data) if @connection
  end

  # get the data in the bound connection
  def get
    @connection.get
  end

  # notify new data
  # if something changes, execute again
  def touch
    @pipe.execute
  end
end
