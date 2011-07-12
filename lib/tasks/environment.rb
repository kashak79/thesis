task :environment do
  $:.unshift File.expand_path("../../../config/", __FILE__)
  load 'environment.rb'
end
