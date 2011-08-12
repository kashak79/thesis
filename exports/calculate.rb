require 'yajl'

truth = Yajl::Parser.new.parse(File.open("../truth/#{ARGV[0]}"))["clusters"].map { |c|
    c.map { |p|
      p["title"].gsub(/[']/,'').gsub(/,/,' ')
    }
  }

export = truth.flatten.map { |c| [c] }


compare = truth.map { |trcluster| 
  export.min_by { |cluster|
    (trcluster-cluster).size 
  }
}

p truth.map { |c| c.size }
p export.map { |cluster| cluster.size}
p export.size

results = truth.zip(compare).map do |pair|
  pr = 1.0 * (pair[0] & pair[1]).size / pair[0].size
  rc = 1.0 * (pair[0] & pair[1]).size / pair[1].size
  ((pr == 0 && rc == 0) || pair[0].size < 1) ? nil : [pr, rc, 2 * pr * rc / (pr + rc), pair[0].size]
end

corr = results.compact.map{|r| r[2] * r[3]}.reduce(:+) / results.compact.map { |r| r[3] }.reduce(:+)
p corr*100

