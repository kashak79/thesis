require 'yajl'

truth = Yajl::Parser.new.parse(File.open("../truth/#{ARGV[0]}"))
export = Yajl::Parser.new.parse(File.open("#{ARGV[1]}"))



h = {}
export.map do |cluster| 
  h[cluster["cluster"]] ||= []
  h[cluster["cluster"]] << cluster["publication"]
end

#p h.min_by { |cluster| (truth["clusters"][5].map { |c| c["title"] } - cluster.last).size }.last

compare = truth["clusters"].map { |tr| 
  l = h.min_by { |cluster| 
    (tr.map { |c| c["title"]}-cluster.last).size 
  }.last
  #[l, (tr.map { |c| c["title"]} - l).size]
}

results = truth["clusters"].map {  |tr| tr.map {|c| c["title"]} }.zip(compare).map do |pair|
  pr = 1.0 * (pair[0] & pair[1]).size / pair[0].size
  rc = 1.0 * (pair[0] & pair[1]).size / pair[1].size
  (pr == 0 && rc == 0) ? nil : [pr, rc, 2 * pr * rc / (pr + rc), pair[0].size]
end

p results.compact.map{|r| r[2]}.reduce(:+) / results.compact.size * 100
p results.compact.map{|r| 1.25 * r[0] * r[1] / (0.25 * r[0] + r[1]) }.reduce(:+) / results.compact.size * 100
