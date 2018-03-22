class CallCounterAggregator
  attr_reader :validated_call_counters

  def initialize
    @counter_durations = [10.minutes, 30.hours, 8.days]
    @validated_call_counters = []
    initialize_first_call_counter
  end

  def aggregate(call_characteristics)
    @current_call = call_characteristics
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

  def in_scope?
    current_call_counter.in_scope?(@current_call.timestamp)
  end

  def initialize_first_call_counter
    @validated_call_counters << Stats::CallCounter.new(
      duration: @counter_durations.shift,
      beginning_time: Time.zone.now
    )
  end

  def move_to_next_call_counter
    next_call_counter = current_call_counter.dup
    next_call_counter.duration = @counter_durations.shift
    @validated_call_counters << next_call_counter
  end

  def current_call_counter
    @validated_call_counters.last
  end

  def compute_aggregation
    current_call_counter.add(@current_call)
  end
end