



# begin with network pipe
$pipe   = (Connections::Local).connection.to(Pipes::Network)

# connect network to bibtex parser
parser  = $pipe.out.connect.to(Parsers::DblpBibtexParser)

# take discoveries apart (and filter the type)
dfilter = parser.out.connect.to(Pipes::Filter.pipe(lambda { |d|
  d if d[:type].is? Core::Discovery
}))

# give them an id
#add_id  = dfilter.out(true).connect(Connections::Async.connection(:persist, :urgent)).to(
#  Pipes::UniqueDiscovery.pipe(Helpers::DistributedIdProvider.new)
#)
add_id  = dfilter.out(true).connect.to(
  Pipes::UniqueDiscovery.pipe(Helpers::DistributedIdProvider.new)
)

# now persist all discoveries
persist = add_id.out.connect.to(
  Pipes::Persist.pipe('http://192.168.179.128:8182/thesis')
)

# place the instance discoveries
placement = persist.out.connect.to(Pipes::Filter.pipe(lambda { |d|
  d if d[:type] == Core::Discovery::INSTANCE
}))

