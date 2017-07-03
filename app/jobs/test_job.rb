class TestJob < ApplicationJob
  def perform
    Rails.logger.info 'This is a Crono test'
  end
end
