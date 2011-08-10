$:.unshift File.expand_path("../lib", __FILE__)

require 'rake'

require 'tasks/environment'
require 'tasks/whitespace'
require 'tasks/graph'
require 'tasks/resque'
require 'tasks/rspec'
require 'tasks/visualize'

require 'audisa/pipes'

require 'redis'

task :test => :environment do
  load 'testpipe.rb'
end

task :stat do
	$redis = Redis.new
	$redis.select 1
  puts "publications: #{$redis.get("stat:pub")}"
  puts ""
  start = $redis.get("stat:start").to_i
  time = (Time.now.to_i-start).to_f/60
  puts "running time: #{time.floor}m #{(time*60)%60}s"
  puts ""
  Pipes::PersistSimilarity::STAT_MAPPING.each do |k,v|
    puts "#{k}: #{$redis.get("stat:#{v}") || 0}"
  end
end

