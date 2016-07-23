module MagicalAsync
  def self.series(tasks, callback)
    case tasks
    when Array
      MagicalAsync._array_series tasks, callback
    when Hash
      MagicalAsync._hash_series tasks, callback
    else
      # TODO: Throw ERROR
    end
  end

  def self._array_series(tasks, callback)
    task_index = 0
    results = []

    next_tasks = -> () {
      return callback.call(nil, results) if task_index == tasks.length

      task_callback = -> (error, arg) {
        puts "callback #{arg}"
        results << arg
        task_index += 1
        next_tasks.call
      }

      tasks[task_index].call task_callback
    }

    next_tasks.call
  end

  def self._hash_series(tasks, callback)
    task_index = 0
    keys = tasks.keys
    results = {}

    next_tasks = -> () {
      return callback.call(nil, results) if task_index == keys.length

      task_callback = -> (error, arg) {
        results[keys[task_index]] = arg
        task_index += 1
        next_tasks.call
      }

      tasks[keys[task_index]].call task_callback
    }

    next_tasks.call
  end
    
end
