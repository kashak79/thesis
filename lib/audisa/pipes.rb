require 'typhoeus'
require 'yajl'
require 'resque'

module Pipes
  autoload :UniqueDiscovery,       'audisa/pipes/unique_discovery'
  autoload :Network,               'audisa/pipes/network'
  autoload :Persistor,             'audisa/pipes/persistor'
  autoload :Stdout,                'audisa/pipes/stdout'
  autoload :Bind,                  'audisa/pipes/bind'
  autoload :Filter,                'audisa/pipes/filter'
end