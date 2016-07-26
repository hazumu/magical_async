require 'thread'
require 'redis'

# TODO
# - timeout
# - APIリクエストでエラーが出たらどこでひろうか?
# - Max thread count
module MagicalAsync
  def self.parallel(tasks, callback)
    results = {}
    threads = []
    redis = Redis.new(host: "localhost", port: 6379)
    tasks.each_pair do |key, task|
      if task.instance_of? CacheableProcess
        unless redis.get(task.redis_key).nil?
          results[key] = redis.get task.redis_key
        else
          threads << Thread.new do
            task.callback.call -> (result) {
              redis.setex task.redis_key, task.redis_expire, result
              results[key] = result
            }
          end
        end
      else
        threads << Thread.new do
          task.call -> (result) {
            results[key] = result
          }
        end
      end
    end

    threads.each(&:join)
    callback.call results
  end
end
