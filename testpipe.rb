# run this file via rake test to load the environment

Core::Pipe.get(:dblp_bibtex).async_execute('http://dblp.uni-trier.de/rec/bibtex/conf/percom/ChenTST11.xml')
Core::Pipe.get(:dblp_bibtex).async_execute('http://dblp.uni-trier.de/rec/bibtex/conf/dbsec/ChenLC11.xml')