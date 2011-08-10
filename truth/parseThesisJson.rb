require 'yajl'

file = ARGV[0]
hash = Yajl::Parser.new.parse(File.new(file))

output = {}

hash['names'].count.times do |index|
	name = hash['names'][index].sub(/ \(.*\).*$/,'').gsub("'",'')
	output[name] = output[name] || {}
	hash['clusters'][index].each do |publication|
		details = {:affiliation => publication['aff'].gsub("'","").gsub(",",' '), :url => publication['url']}
		details[:email] = publication['email'].downcase if !publication['email'].empty?
		output[name][publication['title'].gsub(/[',]/,'')] = details
	end
end

Yajl::Encoder.new.encode(output, File.new("#{file.sub('.json','_parsed.json')}","wb"))