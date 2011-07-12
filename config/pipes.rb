Core::Pipe.define(:dblp_bibtex) do |p|
  p.chain(Pipes::Network).
    #chain(Pipes::Stdout).
    chain(Parsers::DblpBibtexParser).
    #chain(Pipes::Stdout).
    chain(Pipes::UniqueDiscovery, Helpers::DistributedIdProvider.new).
    #chain(Pipes::Stdout).
    chain(Pipes::Persistor, 'http://192.168.179.128:8182/emptygraph')
    #chain(Pipes::Stdout)
end


#
#                /--(name)-- |PossibleAuthors| ------|:possibility-|#############|
#  >---instance--                                                  | NameMatcher |---->
#                \------------(name,id)--------------|:instance----|#############|
#
#Core::Pipe.define(:placement) do |p|
#  local define, every placement pipe has another matcher
#  p.define(:matcher, NameMatcher)
#  p.filter(:name).chain(PossibleAuthors).chain(:matcher, :possibility)
#  p.filter(:name, :id).chain(:matcher, :instance)
#end

# bind the dblp pipe to the placement pipe
Core::Pipe[:dblp_bibtex].chain(Pipes::Bind, :placement)
Core::Pipe.define(:placement) do |p|
  p.filter { |type,instance| instance if type == Core::Discovery::INSTANCE}.
    chain(Pipes::Stdout)
end
