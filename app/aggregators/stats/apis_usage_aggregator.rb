class Stats::ApisUsageAggregator
  def initialize
    @counter_durations = [10.minutes, 30.hours, 8.days]
    @max_duration = 8.days
    @now = Time.zone.now
    @validated_apis_usages = []
    initialize_first_apis_usage
  end

  def aggregate(call_result)
    @current_call = call_result
    return if outside_full_scope?

    move_to_next_apis_usage until in_scope?
    compute_aggregation
  end

  def as_json
    move_to_next_apis_usage until @counter_durations.empty?
    {
      apis_usage: @validated_apis_usages.as_json.reduce({}, :merge)
    }
  end

  private

  def outside_full_scope?
    @current_call.timestamp < (@now - @max_duration)
  end

  def in_scope?
    current_api_usage.in_scope?(@current_call.timestamp)
  end

  def initialize_first_apis_usage
    @validated_apis_usages << Stats::ApisUsage.new(
      scope_duration: @counter_durations.shift,
      beginning_time: @now
    )
  end

  def move_to_next_apis_usage
    next_apis_usage = current_api_usage.dup
    next_apis_usage.scope_duration = @counter_durations.shift
    @validated_apis_usages << next_apis_usage
  end

  def current_api_usage
    @validated_apis_usages.last
  end

  def compute_aggregation
    current_api_usage.add(@current_call)
  end
end
