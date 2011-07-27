require 'nokogiri'
require 'open-uri'
require 'docsplit'
require 'typhoeus'
require 'yajl'

class Pipes::PublicationSearch < Pipes::Pipe

  def initialize()
    super([:in],[:web,:full])
	end

  def execute
		#get the title of the paper
		title = _in.get[:publication][:title]
		bing = Yajl::Parser.parse(open("http://api.search.live.net/json.aspx?Appid=5C0D48683B57FE18427D75AFD802CAB2D1EEA50E&query=#{title.gsub(' ','%20')}%20filetype:pdf&sources=web").read)
		if (bing["SearchResponse"]["Web"]["Total"].to_i > 0 && bing["SearchResponse"]["Web"]["Results"].first["Title"].downcase == title.downcase) then
			response = Typhoeus::Request.get(bing["SearchResponse"]["Web"]["Results"].first["Url"])
			path = title.split.join[0..25]
			file = File.new(path + ".pdf","w+")
			file.puts(response.body)
			file.close
			Docsplit.extract_text(file.path, :pages => [1])
			`rm #{file.path}`
			enrich(:in, :full, :path => path + "_1.txt")
		else
			enrich(:in, :web, :web => _in.get[:publication][:web])
		end

  end

end
