require 'action_view'

class Stats::CallCounter
  include ActionView::Helpers::DateHelper

  attr_reader :beginning_time, :endpoints
  attr_accessor :scope_duration

  EndpointCallCounter = Struct.new(:endpoint, :count) do
    def as_json
      {
        uname: endpoint.uname,
        name: endpoint.name,
        total: count
      }
    end
  end

  def initialize(scope_duration:, beginning_time:)
    @scope_duration = scope_duration
    @beginning_time = beginning_time
    @endpoints = []
  end

  def in_scope?(time)
    time >= (@beginning_time - @scope_duration)
  end

  def add(call_result)
    return false unless in_scope?(call_result.timestamp)

    endpoint_counter = @endpoints.find { |e| e.endpoint.uname == call_result.uname }

    if endpoint_counter.nil?
      @endpoints << EndpointCallCounter.new(call_result, 1)
    else
      endpoint_counter.count += 1
    end
  end

  def total
    @endpoints.map(&:count).inject(0, &:+)
  end

  def as_json
    {
      "last_#{scope_to_words}": {
        total: total,
        by_endpoint: @endpoints.as_json
      }
    }
  end

  private

  def initialize_copy(original)
    @scope_duration = original.scope_duration.dup
    @beginning_time = original.beginning_time.dup
    @endpoints = original.endpoints.deep_dup
  end

  def scope_to_words
    distance_of_time(
      @scope_duration,
      accumulate_on: scope_name_accumulator
    )
      .parameterize
      .underscore
  end

  def scope_name_accumulator
    if @scope_duration < 1.hour
      :minutes
    elsif @scope_duration < 2.days
      :hours
    elsif @scope_duration < 10.days
      :days
    end
  end
end
