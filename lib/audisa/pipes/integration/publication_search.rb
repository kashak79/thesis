require 'docsplit'
require 'typhoeus'
require 'yajl'

class Pipes::PublicationSearch < Pipes::Pipe

  def initialize()
    super([:in],[:web,:full])
	end

  def execute
		#get the title of the paper
		p title = _in.get[:publication][:title].sub(/[.][ ]*$/,'')
		response = Typhoeus::Request.get("http://api.search.live.net/json.aspx",
													:params => {
															:Appid => "5C0D48683B57FE18427D75AFD802CAB2D1EEA50E",
															:query => title + " filetype:pdf",
															:sources => "web"
													})
		bing = Yajl::Parser.parse(response.body)
		p bing
		p "first result :::: " + bing["SearchResponse"]["Web"]["Results"].first["Title"] if bing["SearchResponse"]["Web"]["Total"].to_i > 0
		if (bing["SearchResponse"]["Web"]["Total"].to_i > 0 && bing["SearchResponse"]["Web"]["Results"].first["Title"].downcase == title.downcase) then
			p response = Typhoeus::Request.get(bing["SearchResponse"]["Web"]["Results"].first["Url"])
			path = title.split.join[0..25] + ".pdf"
			file = File.new(path,"w+")
			file.puts(response.body)
			file.close
			enrich(:in, :full, :path => path)
		else
			enrich(:in, :web, :web => _in.get[:publication][:web])
		end
			
  end

end
