class CallCounterAggregator
  def initialize
    @counter_durations = [10.minutes, 30.hours, 8.days]
    @max_duration = 8.days
    @now = Time.zone.now
    @validated_call_counters = []
    initialize_first_call_counter
  end

  def aggregate(call_characteristics)
    @current_call = call_characteristics
    return if outside_full_scope?
    move_to_next_call_counter until in_scope?
    compute_aggregation
  end

  def as_json
    move_to_next_call_counter until @counter_durations.empty?
    {
      number_of_calls: @validated_call_counters.as_json.reduce({}, :merge)
    }
  end

  private

  def outside_full_scope?
    @current_call.timestamp < (@now - @max_duration)
  end

  def in_scope?
    current_call_counter.in_scope?(@current_call.timestamp)
  end

  def initialize_first_call_counter
    @validated_call_counters << Stats::CallCounter.new(
      scope_duration: @counter_durations.shift,
      beginning_time: @now
    )
  end

  def move_to_next_call_counter
    next_call_counter = current_call_counter.dup
    next_call_counter.scope_duration = @counter_durations.shift
    @validated_call_counters << next_call_counter
  end

  def current_call_counter
    @validated_call_counters.last
  end

  def compute_aggregation
    current_call_counter.add(@current_call)
  end
end
