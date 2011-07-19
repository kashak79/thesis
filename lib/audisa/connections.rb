require 'resque'

module Connections
  autoload :Connection,       'audisa/connections/connection'
  autoload :Connector,        'audisa/connections/connector'
  autoload :Local,            'audisa/connections/local'
  autoload :Async,            'audisa/connections/async'
end
