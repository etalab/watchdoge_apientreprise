require 'action_view'

class Stats::CallCounter
  include ActionView::Helpers::DateHelper

  attr_reader :beginning_time, :endpoints
  attr_accessor :duration

  EndpointCallCounter = Struct.new(:endpoint, :count) do
    def as_json
      {
        uname: endpoint.uname,
        name: endpoint.name,
        total: count
      }
    end
  end

  def initialize(duration:, beginning_time:)
    @duration = duration
    @beginning_time = beginning_time
    @endpoints = []
  end

  def initialize_copy(original)
    @duration = original.duration.dup
    @beginning_time = original.beginning_time.dup
    @endpoints = original.endpoints.deep_dup
  end

  def in_scope?(time)
    time >= (@beginning_time - @duration)
  end

  def add(call_characteristics)
    return false unless in_scope?(call_characteristics.timestamp)

    endpoint_counter = @endpoints.find { |e| e.endpoint.uname == call_characteristics.uname }
    if endpoint_counter.nil?
      @endpoints << EndpointCallCounter.new(call_characteristics, 1)
    else
      endpoint_counter.count += 1
    end
  end

  def total
    @endpoints.map(&:count).inject(0, &:+)
  end

  def as_json
    {
      "last_#{duration_name}": {
        total: total,
        by_endpoint: @endpoints.as_json
      }
    }
  end

  private

  def duration_name
    distance_of_time_in_words(
      @beginning_time - @duration,
      @beginning_time,
      true,
      accumulate_on: duration_name_accumulator
    ).parameterize.underscore
  end

  def duration_name_accumulator
    if @duration < 1.hour
      :minutes
    elsif @duration < 2.days
      :hours
    elsif @duration < 10.days
      :days
    end
  end
end