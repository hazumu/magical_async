require 'thread'
require 'thwait'
require "net/http"
require 'benchmark'

# TODO
# - timeout
# - caching
# - APIリクエストでエラーが出たらどこでひろうか?
# MEMO
# - 同じネットワーク内での通信なので通信速度よりもおそらくボトルネックはスレッド数
# - MagicalAsync内でキャッシングするのが筋が良さそう
# - イケてるライブラリ名募集
class MagicalAsync
  def self.waterfall(tasks, callback)
    # TODO: 配列じゃないエラー
    # TODO: 配列が空エラー
    task_index = 0

    next_tasks = -> (args) {
      return callback.call(nil, *args) if task_index == tasks.length

      task_callback = -> (*args) {
        task_index += 1
        next_tasks.call args
      }

      args.push task_callback

      tasks[task_index].call *args
    }

    next_tasks.call []
  end

  def self.paralell(tasks, callback)
    all_result = {}
    threads = []
    tasks.each_pair do |key, task|
      threads << Thread.new do
        task.call -> (result) {
          all_result[key] = result
        }
      end
    end

    threads.each(&:join)
    callback.call all_result
  end
end


#result_serial = Benchmark.realtime do
  #80.times do 
  #  res = Net::HTTP.start("www.yahoo.co.jp") do |http|
  #        http.get "/"
  #  end
  #end
#end
#puts "直列処理  #{result_serial}s"

result_paralell = Benchmark.realtime do

#  tasks = {};
#  0.upto(80) {|num|
#    tasks[num.to_s.to_sym] = -> (callback) {
#      res = Net::HTTP.start("www.yahoo.co.jp") do |http|
#            http.get "/"
#      end
#      callback.call "#{num}番目"
#    }
#  }
#  MagicalAsync.paralell(tasks, -> (res) { puts res })
#

  MagicalAsync.paralell({
     first: -> (callback) {
       res = Net::HTTP.start("www.yahoo.co.jp") do |http|
             http.get "/"
       end
       callback.call 'first'
     },
     second: -> (callback) {
       tasks = {};
       0.upto(80) { |num|
         tasks[num.to_s.to_sym] = -> (callback) {
           res = Net::HTTP.start("www.yahoo.co.jp") do |http|
                 http.get "/"
           end
           callback.call "#{num}番目"
         }
       }
       MagicalAsync.paralell(tasks, -> (res) { puts res; callback.call 'second';})
     },
     third: -> (callback) {
       res = Net::HTTP.start("www.yahoo.co.jp") do |http|
             http.get "/"
       end
       callback.call 'third' 
     },
   }, -> (res) { puts res });
 end
 puts "並列処理 #{result_paralell}s"



#MagicalAsync.waterfall([
#  -> (callback) {
#    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
#      http.get "/"
#    end
#    callback.call 'first'
#  },
#  -> (data, callback) {
#    puts data
#    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
#     http.get "/"
#    end
#    callback.call 'second', 'tanaka'
#  },
#  -> (data, name, callback) {
#    puts "#{data} , #{name}"
#    res = Net::HTTP.start("www.yahoo.co.jp") do |http|
#     http.get "/"
#    end
#    callback.call 'third'
#  }
#], -> (err, data) {puts data})
