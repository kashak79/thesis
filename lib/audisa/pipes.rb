require 'typhoeus'
require 'yajl'

module Pipes
  autoload :Pipe,                  'audisa/pipes/pipe'
  autoload :UniqueDiscovery,       'audisa/pipes/unique_discovery'
  autoload :Network,               'audisa/pipes/network'
  autoload :Persist,               'audisa/pipes/persist'
  autoload :Stdout,                'audisa/pipes/stdout'
  autoload :Filter,                'audisa/pipes/filter'
end
