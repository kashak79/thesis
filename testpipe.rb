# initialize
graph = Helpers::Rexster.new('http://192.168.179.128:8182/thesis')
graph.clear
graph.create_index(:family)
graph.create_index(:name)
$redis.flushdb

# pipe.to(Pipes::Network).
 # out.connect.to(Parsers::DblpAuthorParser).
 # out.connect.to(Pipes::Network).
 # out.connect.to(Parsers::DblpBibtexParser).
 # out.connect.to(Pipes::Filter.pipe(lambda { |flow|
  # flow.reject_keys(:type) if flow[:type].eq?(:discovery, :publication)
 # })).
 # out(true).connect.to(Pipes::PublicationSearch).out(:full).connect.to(Pipes::Stdout)

 # test
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/PauwTO11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/SteurbautT11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/cluster/BosscheVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/fgcs/DeboosereSWVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/ijcomsys/SimoensVDATDD11.xml')

$pipe.push(:url => 'http://dblp.uni-trier.de/db/indices/a-tree/t/Turck:Filip_De.html')


# w.out("published").in("published").except([w]).aggregate(x)
# w.out("name").in("name").except([w]).out("published").in("published").as("y").out("name").in("name").retain(x).as("z").table(t){it.name}{it.name}.count()
# w.out("name").in("name").except([w]).out("published").as("x").in("published").as("y").out("name").in("name").retain(x).as("z").table(t){it.title}{it.name}{it.name}.count()

# http://192.168.179.128:8182/thesis/vertices/7739/tp/gremlin?script=t=new%20Table();v.out(%22name%22).in(%22name%22).except([v]).out(%22published%22).in(%22published%22).as(%22y%22).out(%22name%22).in(%22name%22).retain(v.out(%22published%22).in(%22published%22).except([v])%20%3E%3E%20(v.out(%22published%22).in(%22published%22).except([v]).count().toInteger())).as(%22z%22).table(t){it.id}{it.id}.cap

# pipe.push(:url => "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/s/Smith:Jim.html")

# pipe.to(Pipes::AuthorSearch).
	# out.connect.to(Pipes::Stdout)
	
pipe.to(Pipes::PublicationText)
	.out.connect.to(Pipes::Stdout)
	
pipe.push(:full => {:path => "JCDL-2004-author-disambiguation.pdf"})

#pipe.push({:publication => "Two Supervised Learning Approaches for Name Disambiguation in Author Citations", :author => { :name => "Kostas Tsioutsiouliklis" }, :full => {:path => "JCDL-2004-author-disambiguation_1.txt" }})

#$pipe.in.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/percom/ChenTST11.xml')