require 'engtagger'

graph = Helpers::Rexster.new('http://192.168.179.128:8182/thesis')
dependency = Pipes::Dependency.pipe

$pipe = (Connections::Local).connection

depmerge = Pipes::Merge.pipe(2)
depmerge.out.connect.to(dependency, :resolve)

dblp = $pipe.to(Pipes::Network).
  out.connect.to(Parsers::DblpAuthorParser).
  #out.connect(Connections::Async.connection(:publication, :urgent)).to(Pipes::Network).
  out.connect.to(Pipes::Network).
	# out.connect.to(Pipes::Filter.pipe(lambda { |flow|
		# $count ||= 0
		# $count += 1
		# $count < 50 ? flow : false
	# })).
  out.connect.to(Parsers::DblpBibtexParser)

# connect all parsers to the dependency store
dblp.out.connect.to(dependency, :store)

# filter out the instance  discoveries and integrate them in the graph
# then connect to the dependency resolver
instance_filter = dependency.out.connect.to(Pipes::Filter.pipe(lambda { |flow|
  flow.reject_keys(:type) if flow[:type].eq?(:discovery, :instance)
}))
# integrate and resolve
instance_filter.out(true).connect.to(Pipes::Integration.pipe(graph)).
  out.connect.to(depmerge, 1)

# filter the discoveries and persist them
# then connect to the dependency resolver
discovery_filter = instance_filter.out(false).connect.to(Pipes::Filter.pipe(lambda { |flow|
  flow.reject_keys(:type) if flow[:type].is? :discovery
}))

discovery_filter.out(true).connect.to(Pipes::PersistDiscovery.pipe(graph, :publication)).
	out.connect.to(Pipes::PublicationTitlePosTagging.pipe(EngTagger.new)).
	out.connect.to(Pipes::PersistDiscovery.pipe(graph, :keywords, :index => :keyword)).
	out.connect.to(Pipes::PersistFact.pipe(graph, :publication, :keywords, :keyword)).
  out.connect.to(depmerge, 2)

rule_split = discovery_filter.out(false).connect.to(Pipes::PersistFact.pipe(graph, :instance, :publication, :published)).
	out.connect.to(Pipes::MagicFacts.pipe(graph, File.open('truth/mens2_parsed.json','r'))).
	out.connect.to(Pipes::Split.pipe(4))
	
# clustering
clusterer = Pipes::Merge.pipe(4)
clusterer.out.connect.to(Pipes::PersistSimilarity.pipe(graph))
# clusterer.out.connect.to(Pipes::Stdout)
	
# keywords rule
rule_split.out(1).connect.to(Pipes::KeywordsRule.pipe(graph)).
  out.connect.to(clusterer, 1)
	
# email rule
rule_split.out(2).connect.to(Pipes::PersistDiscovery.pipe(graph, :email, :index => :email)).
	out.connect.to(Pipes::PersistFact.pipe(graph, :instance, :email, :email)).
	out.connect.to(Pipes::EmailRule.pipe(graph)).
	out.connect.to(clusterer, 2)

# affiliation rule
rule_split.out(3).connect.to(Pipes::PersistFact.pipe(graph, :instance, :affiliation, :affiliation)).
	out.connect.to(Pipes::AffiliationRule.pipe(graph, Helpers::AffiliationMatcher.new)).
	out.connect.to(clusterer, 3)
	
# co-author rule
rule_split.out(4).connect.to(Pipes::CoAuthorRule.pipe(graph)).
	out.connect.to(clusterer,4)