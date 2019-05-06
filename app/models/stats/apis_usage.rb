require 'action_view'

class Stats::ApisUsage
  include ActionView::Helpers::DateHelper

  attr_reader :beginning_time, :endpoints
  attr_accessor :scope_duration

  EndpointUsageCounter = Struct.new(:endpoint, :count, :success_count, :client_errors_count, :server_errors_count) do
    def initialize(ept)
      self.endpoint = ept
      self.count = 0
      self.success_count = self.client_errors_count = self.server_errors_count = 0.0
    end

    def as_json
      {
        uname: endpoint.uname,
        name: endpoint.name,
        total: count,
        percent_success: (success_count / count * 100).round(1),
        percent_client_errors: (client_errors_count / count * 100).round(1),
        percent_server_errors: (server_errors_count / count * 100).round(1)
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

    @api_usage_counter = @endpoints.find { |e| e.endpoint.uname == call_result.uname }

    if @api_usage_counter.nil?
      @api_usage_counter = EndpointUsageCounter.new(call_result)
      @endpoints << @api_usage_counter
    end

    increase_counter(call_result)
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

  def increase_counter(call_result)
    @api_usage_counter.count += 1
    @api_usage_counter.success_count += 1 if call_result.code.to_s =~ /^2\d+$/
    @api_usage_counter.client_errors_count += 1 if call_result.code.to_s =~ /^4\d+$/
    @api_usage_counter.server_errors_count += 1 if call_result.code.to_s =~ /^5\d+$/
  end

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
