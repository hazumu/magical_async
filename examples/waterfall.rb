require "net/http"
require 'benchmark'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../lib"))
require 'magical_async'

TEST_URI = URI.parse('http://localhost:8081/swagger-ui.html')
# TEST_URI = URI.parse('http://google.com') # name resolution process is very slow.
# TEST_URI = URI.parse('http://216.58.197.142')

MagicalAsync.waterfall([
  -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
      http.get "/"
    end
    callback.call 'first'
  },
  -> (data, callback) {
    puts data
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call 'second_1', 'second_2'
  },
  -> (data, name, callback) {
    puts "#{data} , #{name}"
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call 'third'
  }
], -> (err, data) {puts data})
