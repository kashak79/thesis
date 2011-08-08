$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'bundler/setup'

require 'amatch'
require 'resque'
require 'redis'
require 'nokogiri'
require 'typhoeus'
require 'yajl'
require 'redis-lock'

include Amatch

$redis = Redis.new

require 'audisa/core'
require 'audisa/pipes'
require 'audisa/connections'
require 'audisa/helpers'
require 'audisa/parsers'

load 'config.rb'
load 'pipes.rb'

# hash symbolize
class Hash
  def symbolize!
    adding = Hash.new
    self.each do |k,v|
      adding[k.to_sym] = v
      self.delete(k)
    end
    adding.each do |k,v|
      self[k] = if v.kind_of?(Hash)
        v.symbolize!
      elsif v.kind_of?(Array)
        v.map { |h| h.kind_of?(Hash) ? h.symbolize! : h }
      else
        v
      end
    end
  end

  def reject_keys(*keys)
    reject { |k,v| keys.include? k }
  end
end