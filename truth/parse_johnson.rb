require 'yajl'

hash = Yajl::Parser.new.parse(File.new("johnson.json"))
aff = Yajl::Parser.new.parse(File.new("aff.json")).merge(Yajl::Parser.new.parse(File.new("aff2.json"))).merge(Yajl::Parser.new.parse(File.new("aff3.json")))


output = {}

hash['names'].count.times do |index|
	name = hash['names'][index].sub(/ \(.*\).*$/,'')
	output[name] = output[name] || {}
	hash['clusters'][index].each do |publication|
		details = {:affiliation => aff[publication['title']] ? aff[publication['title']].gsub("'",'').gsub(',',' ') : "", :url => publication['url']}
		details[:email] = publication['email'].downcase if !publication['email'].empty?
		output[name][publication['title'].gsub("'","")] = details
	end
end

Yajl::Encoder.new.encode(output, File.new("johnson_parsed.json","wb"))