require 'redis'

module MagicalAsync
  def self.waterfall(tasks, callback)
    # TODO: 配列じゃないエラー
    # TODO: 配列が空エラー
    task_index = 0
    redis = Redis.new(host: "localhost", port: 6379)

    next_tasks = -> (args) {
      return callback.call(nil, *args) if task_index == tasks.length

      task = tasks[task_index]

      if task.instance_of? CacheableProcess
        unless redis.get(task.redis_key).nil?
          args << redis.get(task.redis_key)
          task_index += 1
          next_tasks.call args
        else
          task_callback = -> (*args) {
            # TODO: multi parameter
            redis.setex task.redis_key, task.redis_expire, args[0]
            task_index += 1
            next_tasks.call args
          }

          args << task_callback

          task.callback.call *args
        end
      else
        task_callback = -> (*args) {
          task_index += 1
          next_tasks.call args
        }

        args << task_callback

        task.call *args
      end
    }

    next_tasks.call []
  end
end
