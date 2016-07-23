require "net/http"
require 'benchmark'
dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'magical_async')

MagicalAsync.waterfall([
  -> (callback) {
    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
      http.get "/"
    end
    callback.call 'first'
  },
  -> (data, callback) {
    puts data
    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
     http.get "/"
    end
    callback.call 'second', 'tanaka'
  },
  -> (data, name, callback) {
    puts "#{data} , #{name}"
    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
     http.get "/"
    end
    callback.call 'third'
  }
], -> (err, data) {puts data})
