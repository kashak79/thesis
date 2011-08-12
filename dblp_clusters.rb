require 'typhoeus'
require 'nokogiri'
require 'yajl'

dblp = [{:name => "woo2", :links => ['http://dblp.uni-trier.de/db/indices/a-tree/w/Woo:Chong.html',
    'http://dblp.uni-trier.de/db/indices/a-tree/w/Woo:Chong=Woo.html',
    'http://dblp.uni-trier.de/db/indices/a-tree/w/Woo:Chongwoo.html']},
  {:name => "yuchen", :links => ['http://dblp.uni-trier.de/db/indices/a-tree/c/Chen:Yu.html']},
  {:name => "mens2", :links => ['http://dblp.uni-trier.de/db/indices/a-tree/m/Mens:Tom.html','http://dblp.uni-trier.de/db/indices/a-tree/m/Mens:Kim.html']},
  {:name => "johnson", :links => ["http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_A=_H=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_Aaron.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_B=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_D=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_E=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_G=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_H=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_R=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_Randolph.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:D=_T=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dabney.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dale_A=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dale_M=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Damian.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dan.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dana.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dana_M=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daniel.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daniel_Ezra.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daniel_P=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daniel_R=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daphne.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Darin.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Darin_B=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Darrel_Eric.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Daryl.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dave.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_A=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_B=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_C=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_E=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_H=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_K=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_L=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_Lloyd.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_O=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_R=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_S=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:David_W=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dean.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Deborah_G=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Delia.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Derek.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Derek_M=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Desiree_C=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Diane_Tobin.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dianne.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Dion_L=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Don.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Don_H=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Don_W=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Donald.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Donald_B=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Donald_Byron.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Donald_W=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Donna_L=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Doug.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Doug_V=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Douglas.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Douglas_A=.html", "http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/j/Johnson:Duane_D=.html"]}]

result = {}

#dblp.each do |author|
  author = dblp[2]
  result[author[:name]] = []
  author[:links].each do |url_dblp|
    result[author[:name]] << t = []
    body = Typhoeus::Request.get(url_dblp).body
    body.scan(/href="([^"]*\.xml)"/).flatten.each do |url|
      xml = Nokogiri::XML(Typhoeus::Request.get(url).body)
      t << (xml.root % 'title').text.gsub(/[',]/,'')
    end
  end
#end


result.each do |name, clusters|

  truth = Yajl::Parser.new.parse(File.open("./truth/#{name}.json"))
  
  compare = truth["clusters"].map do |tr|
    l = clusters.min_by do |cluster|
      (tr.map { |c| c["title"].gsub(/[',]/,'')}-cluster).size
    end
  end
  
  results = truth["clusters"].map {  |tr| tr.map {|c| c["title"].gsub(/[',]/,'')} }.zip(compare).map do |pair|
    pr = 1.0 * (pair[0] & pair[1]).size / pair[0].size
    rc = 1.0 * (pair[0] & pair[1]).size / pair[1].size
    (pr == 0 && rc == 0) ? nil : [pr, rc, 2 * pr * rc / (pr + rc), pair[0].size]
  end
  
  y_1 = results.compact.map{|r| r[2]}.reduce(:+) / results.compact.size * 100
  y_5 = results.compact.map{|r| 1.25 * r[0] * r[1] / (0.25 * r[0] + r[1]) }.reduce(:+) / results.compact.size * 100
  y_w = results.compact.map{|r| r[2] * r[3]}.reduce(:+) / results.compact.map { |r| r[3] }.reduce(:+) * 100
  
  puts "#{name} ::: Y_1 = #{y_1}, Y_.5 = #{y_5}, Y_weighted = #{y_w}"
end
