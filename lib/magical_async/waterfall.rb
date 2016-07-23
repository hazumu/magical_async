module MagicalAsync
  def waterfall(tasks, callback)
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
end
