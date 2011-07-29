require 'choice'
require 'nokogiri'
require 'typhoeus'
require 'yajl'
require 'cgi'

# define command line options
Choice.options do
  option :urls do
    short '-n'
    default 1
    cast Integer
  end
  option :file do
    short '-f'
    default 'truth.json'
  end
end

puts "
#########################################################################################################
############################################# TRUTH BUILDER #############################################
#########################################################################################################
"

# get number of urls
urls = Choice[:urls]
# get save file
file = Choice[:file]
# clusters made so far
clusternames = []
# decision made so far
clusters = []
# coauthors
ccoauthors = []

def separate
  puts "#########################################################################################################"
end

# source url's
sources = []

# load johnson
john = Nokogiri::XML(File.open('johnson')).root
john.xpath('//a').map { |j| j['href'] }.each do |s|
  sources << s
end

# enter the source url's
puts "Enter the source DBLP url's"
urls.times do |i|
  print "#{i}: "
  #sources << STDIN.gets.strip
end

separate

# process each publication
sources.each do |source|
  puts "Processing #{source}"
  separate
  # parse page as xml
  authordoc = Nokogiri::XML(Typhoeus::Request.get(source).body).root
  name = authordoc.xpath("//h1/text()").text.strip
  # get the links
  nodes = authordoc.xpath('//img[@alt="bibliographical record in XML"]')
  nodes.each do |node|
    link = node.parent[:href]
    # get the bibtex
    bibtexdoc = Nokogiri::XML(Typhoeus::Request.get(link).body).root
    # separate
    separate
    # inform progress
    puts "(#{sources.index(source)+1}/#{sources.size}) (#{nodes.index(node)+1}/#{nodes.size})"
    # show title
    title = bibtexdoc.at('title').text
    puts "Title: #{title}"
    # year
    year = bibtexdoc.at('year').text
    puts "Year: #{year}"
    # show authors
    coauthors = []
    puts "Authors:"
    (bibtexdoc / 'author').each do |author|
      coauthors << author.text if author.text!=name
      puts "* #{author.text}"
    end
    # Search
    puts "Search: http://scholar.google.com/scholar?q=#{CGI::escape("\"#{title}\"")}"
    # give url
    print "Url of publication: "
    url = STDIN.gets.strip
    # cluster decision
    puts "Make your cluster decision! (number to assign to existing; name to make new)"
    puts "choices:"
    max_common = 0
    max_index = 0
    clusternames.each_index do |i|
      common = coauthors.select { |co| (ccoauthors[i] || []).include?(co) }.count
      if common > max_common
        max_common = common
        max_index = i
      end
      puts "#{i+1}. #{clusternames[i]} (#{common} coauthors in common)"
    end
    puts "(no choices yet)" if clusternames.empty?

    print "decision (suggestion: #{max_index+1}): "
    decision = STDIN.gets.strip
    if decision == ""
      cluster = max_index
    elsif decision.to_i == 0
      # does the cluster exist?
      if clusternames.index("#{name} (#{decision})")
        cluster = clusternames.index("#{name} (#{decision})")
      else
        # make a new cluster
        cluster = clusternames.size
        clusternames << "#{name} (#{decision})"
      end
    else
      cluster = decision.to_i-1
    end
    # put decision in right cluster
    clusters[cluster] ||= []
    clusters[cluster] << {:title => title, :url => url}
    ccoauthors[cluster] = ((ccoauthors[cluster] || []) + coauthors).uniq
    # save after each publication
    File.open(file, 'w') do |f|
      f.write(Yajl::Encoder.encode(clusters))
    end
  end
end
