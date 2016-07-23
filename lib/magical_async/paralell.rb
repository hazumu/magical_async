require 'thread'

# TODO
# - timeout
# - caching
# - APIリクエストでエラーが出たらどこでひろうか?
# MEMO
# - 同じネットワーク内での通信なので通信速度よりもおそらくボトルネックはスレッド数
# - MagicalAsync内でキャッシングするのが筋が良さそう
module MagicalAsync
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
