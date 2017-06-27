class TestJob < ActiveJob::Base
  def perform
    puts "This is a Crono test"
  end
end
