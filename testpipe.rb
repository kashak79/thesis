pipe = (Connections::Local).connection

# pipe.to(Pipes::Network).
 # out.connect.to(Parsers::DblpAuthorParser).
 # out.connect.to(Pipes::Network).
 # out.connect.to(Parsers::DblpBibtexParser).
 # out.connect.to(Pipes::Filter.pipe(lambda { |flow|
  # flow.reject_keys(:type) if flow[:type].eq?(:discovery, :publication)
 # })).
 # out(true).connect.to(Pipes::PublicationSearch).out(:full).connect.to(Pipes::Stdout)


# pipe.push(:url => "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/s/Smith:Jim.html")

# pipe.to(Pipes::AuthorSearch).
	# out.connect.to(Pipes::Stdout)
	
pipe.to(Pipes::PublicationText)
	.out.connect.to(Pipes::Stdout)
	
pipe.push(:full => {:path => "JCDL-2004-author-disambiguation.pdf"})

#pipe.push({:publication => "Two Supervised Learning Approaches for Name Disambiguation in Author Citations", :author => { :name => "Kostas Tsioutsiouliklis" }, :full => {:path => "JCDL-2004-author-disambiguation_1.txt" }})

#$pipe.in.push(:url => 'http://dblp.uni-trier.de/rec/bibtex/conf/percom/ChenTST11.xml')
