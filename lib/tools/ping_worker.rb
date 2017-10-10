class Tools::PingWorker
  def initialize(elements, thread_number = Rails.application.config.thread_number)
    @queue = elements.inject(Queue.new, :enq)

    @threads = Array.new(thread_number) do
      Thread.new do
        until @queue.empty?
          element = @queue.deq

          yield element
        end
      end
    end

    @threads.each(&:join)
  end
end
