class Parsers::DblpBibtexParser < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    # parse page as xml
    document = Nokogiri::XML(_in.get)
    # get the root
    root = document.root
    # first push the publication itself
    publication = out.push(:type => Core::Discovery::PUBLICATION, :title => (root % 'title').text)
    # push the authors
    (root / 'author').each do |author_node|
      # report discovery of a new instance
      author = out.push(:type => Core::Discovery::INSTANCE, :name => author_node.text)
    end
  end

end
