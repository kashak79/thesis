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

load 'pipes.rb'
