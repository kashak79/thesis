class Parsers::DblpBibtexParser < Core::Pipe

  def execute(page)
    # parse page as xml
    document = Nokogiri::XML(page)
    # get the root
    root = document.root
    # first push the publication itself
    publication = push(Core::Discovery::PUBLICATION, :title => (root % 'title').text)
    # push the authors
    (root / 'author').each do |author_node|
      # report discovery of a new instance
      author = push(Core::Discovery::INSTANCE, :name => author_node.text)
    end
  end

end
