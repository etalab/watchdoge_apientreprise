class Tools::PingWorker
  def run(elements, thread_number = Rails.application.config.thread_number)
    elements.each do |e|
      yield e
    end
  end
end
