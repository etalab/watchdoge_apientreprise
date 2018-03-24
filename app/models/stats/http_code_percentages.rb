class Stats::HttpCodePercentages
  include ActionView::Helpers::DateHelper

  attr_reader :beginning_time, :http_code_counters, :number_of_calls
  attr_accessor :scope_duration

  def initialize(scope_duration:, beginning_time:)
    @scope_duration = scope_duration
    @beginning_time = beginning_time
    @http_code_counters = {}
    @number_of_calls = 0
  end

  def in_scope?(time)
    time >= (@beginning_time - @scope_duration)
  end

  def add(call_characteristics)
    return false unless in_scope?(call_characteristics.timestamp)

    if @http_code_counters.key?(call_characteristics.code)
      @http_code_counters[call_characteristics.code] += 1
    else
      @http_code_counters[call_characteristics.code] = 1
    end

    @number_of_calls += 1
  end

  def as_json
    {
      "last_#{scope_to_words}": http_code_percentages_as_json
    }
  end

  private

  def initialize_copy(original)
    @scope_duration = original.scope_duration
    @beginning_time = original.beginning_time
    @http_code_counters = original.http_code_counters.deep_dup
    @number_of_calls = original.number_of_calls
  end

  def http_code_percentages_as_json
    @http_code_counters.map { |k, v| { "#{k}": (v / number_of_calls.to_f * 100).round(1) } }
  end

  def scope_to_words
    distance_of_time_in_words(
      @beginning_time - @scope_duration,
      @beginning_time,
      true,
      accumulate_on: scope_name_accumulator
    ).parameterize.underscore
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
