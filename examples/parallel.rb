require "net/http"
require 'benchmark'
require 'uri'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../lib"))
require 'magical_async'

# TEST_URI = URI.parse('http://localhost:8081/swagger-ui.html')
# TEST_URI = URI.parse('http://google.com') # name resolution process is very slow.
# TEST_URI = URI.parse('http://216.58.197.142')
TEST_URI = URI.parse('http://hazumu.net/blog/')
REQUEST_COUNT = 80

result_serial = Benchmark.realtime do
  REQUEST_COUNT.times do 
    res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
      http.get "/"
    end
  end
end
puts "serial process #{result_serial}s"

result_parallel = Benchmark.realtime do
  REDIS_EXPIRE = 100

  MagicalAsync.parallel({
     first: MagicalAsync.cacheable('url_1', REDIS_EXPIRE, -> (callback) {
       res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
         http.get "/"
       end
       callback.call 'first'
     }),

     second: -> (callback) {

       MagicalAsync.waterfall([
         MagicalAsync.cacheable('url_2', REDIS_EXPIRE, -> (callback) {
           res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
             http.get "/"
           end
           callback.call 'second_1'
         }), 
         -> (res, callback) { 
           tasks = {};
           0.upto(REQUEST_COUNT) { |num|
             tasks[num.to_s.to_sym] = MagicalAsync.cacheable("url_2_#{num}", REDIS_EXPIRE, -> (callback) {
               res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
                 http.get "/"
               end
           
               callback.call "call number -> #{num}"
             })
           }
           
           MagicalAsync.parallel(tasks, -> (res) { puts res; callback.call 'second_2';})
         },
         -> (res, callback) { 
           puts 'second_3'
           callback.call 'second_3'
         },
     ],
       -> (err, res) {
         callback.call 'second'
       })

     },
     third: -> (callback) {
       res = Net::HTTP.start(TEST_URI.host, TEST_URI.port) do |http|
         http.get "/"
       end
       callback.call 'third' 
     },
   }, -> (res) { puts res });
  end
puts "parallel process #{result_parallel}s"
