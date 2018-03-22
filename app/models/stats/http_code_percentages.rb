class Stats::HttpCodePercentages
  include ActionView::Helpers::DateHelper

  attr_reader :beginning_time, :http_code_counters, :number_of_calls
  attr_accessor :duration

  def initialize(duration:, beginning_time:)
    @duration = duration
    @beginning_time = beginning_time
    @http_code_counters = {}
    @number_of_calls = 0
  end

  def initialize_copy(original)
    @duration = original.duration
    @beginning_time = original.beginning_time
    @http_code_counters = original.http_code_counters.deep_dup
    @number_of_calls = original.number_of_calls
  end

  def in_scope?(time)
    time >= (@beginning_time - @duration)
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
      "last_#{duration_name}": http_code_percentages_as_json
    }
  end

  private

  def http_code_percentages_as_json
    @http_code_counters.map { |k, v| { "#{k}": (v / number_of_calls.to_f * 100).round(1) } }
  end

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
