$:.unshift File.expand_path("../lib", __FILE__)

require 'rake'

require 'tasks/environment'
require 'tasks/whitespace'
require 'tasks/graph'
require 'tasks/resque'
require 'tasks/rspec'

task :test => :environment do
  load 'testpipe.rb'
end