class Parsers::DblpAuthorParser < Pipes::Pipe

  def initialize
    super()
  end

  def execute
    # parse page as xml
    document = Nokogiri::XML(_in.get)
    # get the root
    root = document.root
    # get the links
    root.xpath('//img[@alt="bibliographical record in XML"]').each do |node|
      out.push(:url => node.parent[:href])
    end
  end

end
