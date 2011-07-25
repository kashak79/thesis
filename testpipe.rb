# initialize
graph = Helpers::Rexster.new('http://192.168.179.128:8182/thesis')
graph.clear
graph.create_index(:family)
graph.create_index(:name)
$redis.flushdb

# test
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/PauwTO11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/SteurbautT11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/cluster/BosscheVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/fgcs/DeboosereSWVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/ijcomsys/SimoensVDATDD11.xml')

$pipe.push(:url => 'http://dblp.uni-trier.de/db/indices/a-tree/t/Turck:Filip_De.html')


# w.out("name").in("name").except([w]).out("published").in("published").as("y").out("name").in("name").retain(x).as("z").table(t){it.name}{it.name}.count()
# w.out("name").in("name").except([w]).out("published").as("x").in("published").as("y").out("name").in("name").retain(x).as("z").table(t){it.title}{it.name}{it.name}.count()