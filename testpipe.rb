$:.unshift File.expand_path("../lib", __FILE__)

require 'audisa/core'
require 'audisa/helpers'
require 'audisa/parsers'

pipe = Core::Pipe.new do |p|
  p.chain(Helpers::Network.new).
    chain(Parsers::DblpBibtexParser.new).
    chain(Helpers::UniqueDiscovery.new(Helpers::SimpleIdProvider.new)).
    chain(Helpers::Persistor.new('http://192.168.179.128:8182/emptygraph')).
    chain(Helpers::Stdout.new)
end

pipe.execute('http://dblp.uni-trier.de/rec/bibtex/conf/dbsec/ChenLC11.xml')
# pipe.execute('http://dblp.uni-trier.de/rec/bibtex/conf/percom/ChenTST11.xml')
