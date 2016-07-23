require "net/http"
require 'benchmark'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../lib"))
require 'magical_async'

TEST_URI = URI.parse('http://localhost:8081/swagger-ui.html')
# TEST_URI = URI.parse('http://google.com') # name resolution process is very slow.
# TEST_URI = URI.parse('http://216.58.197.142')

MagicalAsync.series([
  -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
      http.get "/"
    end
    callback.call nil, 'first'
  },
  -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call nil, 'second'
  },
  -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call nil, 'third'
  }
], -> (err, results) {print results})

MagicalAsync.series({
  first: -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
      http.get "/"
    end
    callback.call nil, 'first'
  },
  second: -> (callback) {
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call nil, 'second'
  },
  third: -> (callback) {
    sleep 3
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
     http.get "/"
    end
    callback.call nil, 'third'
  }
}, -> (err, results) {puts results})
