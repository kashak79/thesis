pipe = (Connections::Local).connection

pipe.to(Pipes::Network).
 out.connect.to(Parsers::DblpAuthorParser).
 out.connect.to(Pipes::Network).
 out.connect.to(Parsers::DblpBibtexParser).
 out.connect.to(Pipes::PublicationSearch).out(:full).connect.to(Pipes::Stdout)


pipe.push(:url => "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/b/Bork:Peer.html")
#$pipe.in.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/percom/ChenTST11.xml')
