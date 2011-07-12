require 'redis'

module Helpers
  autoload :SimpleIdProvider,      'audisa/helpers/simple_id_provider'
  autoload :DistributedIdProvider, 'audisa/helpers/distributed_id_provider'
end
