class Parsers::DblpBibtexParser < Pipes::Pipe

  def initialize
    super()
    @reference = Helpers::DistributedIdProvider.new
  end

  def execute
    $redis.incr("stat:pub")
    # parse page as xml
    document = Nokogiri::XML(_in.get)
    # get the root
    root = document.root
    # first push the publication itself
    out.push(
      :type => Core::Type.new(:discovery, :publication),
      :reference => pub_ref=@reference.get,
      :publication => {
        :title => (root % 'title').text.gsub(/[',]/,'')
      }
    )
    # push the authors
    (root / 'author').each do |author_node|
      # report discovery of a new instance
      out.push(
        :type => Core::Type.new(:discovery, :instance),
        :reference => auth_ref=@reference.get,
        :instance => {
          :name => author_node.text.gsub(/'/,'')
        }
      )
      # report the fact that this author published the publication
      out.push(
        :type => Core::Type.new(:fact, :published),
        :dependencies => [pub_ref, auth_ref]
      )
    end
  end

end
