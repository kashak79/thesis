require 'nokogiri'

class Parsers::DblpBibtexParser < Core::Pipe

  def execute(page)
    # parse page as xml
    document = Nokogiri::XML(page)
    # get the root
    root = document.root
    # first push the publication itself
    publication = push(Core::Discovery::PUBLICATION, :title => (root % 'title').text)
  end

end
