Core::Pipe.define(:dblp_bibtex) do |p|
  p.chain(Helpers::Network).
    #chain(Helpers::Stdout).
    chain(Parsers::DblpBibtexParser).
    #chain(Helpers::Stdout).
    chain(Helpers::UniqueDiscovery, Helpers::DistributedIdProvider.new).
    #chain(Helpers::Stdout).
    chain(Helpers::Persistor, 'http://192.168.179.128:8182/emptygraph').
    #chain(Helpers::Stdout).
    chain(Helpers::Stdout)
end
