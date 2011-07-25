# initialize
graph = Helpers::Rexster.new('http://192.168.179.128:8182/testgraph')
graph.clear
graph.create_index(:family)
graph.create_index(:name)
$redis.flushdb

# test
$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/PauwTO11.xml')
$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/aims/SteurbautT11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/cluster/BosscheVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/fgcs/DeboosereSWVTDD11.xml')
#$pipe.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/journals/ijcomsys/SimoensVDATDD11.xml')
