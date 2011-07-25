module Pipes
  autoload :Pipe,                  'audisa/pipes/pipe'
  autoload :UniqueDiscovery,       'audisa/pipes/unique_discovery'
  autoload :Network,               'audisa/pipes/network'
  autoload :Persist,               'audisa/pipes/persist'
  autoload :Stdout,                'audisa/pipes/stdout'
  autoload :Filter,                'audisa/pipes/filter'
  autoload :Split,                 'audisa/pipes/split'
  autoload :Merge,                 'audisa/pipes/merge'
  autoload :Dependency,            'audisa/pipes/dependency'

  # integration pipes
  autoload :Integration,           'audisa/pipes/integration/integration'
  autoload :NameMatching,          'audisa/pipes/integration/name_matching'
  autoload :PersistFamily,         'audisa/pipes/integration/persist_family'
  autoload :PersistInstance,       'audisa/pipes/integration/persist_instance'
  autoload :PersistName,           'audisa/pipes/integration/persist_name'

  autoload :PersistDiscovery,      'audisa/pipes/persist_discovery'
  autoload :PersistFact,           'audisa/pipes/persist_fact'

end
