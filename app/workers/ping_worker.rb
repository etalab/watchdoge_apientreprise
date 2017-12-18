class PingWorker
  include Sidekiq::Worker

  def perform(arg)
    case arg
    when 'easy'
      sleep 2
      puts 'easy oki'
    when 'hard'
      sleep 10
      puts 'hard job'
      raise 'error!!!!'
    end
  end
end
