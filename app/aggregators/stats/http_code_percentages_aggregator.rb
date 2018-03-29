class Stats::HttpCodePercentagesAggregator
  def initialize
    @code_percentages_durations = [30.hours, 8.days]
    @max_duration = 8.days
    @now = Time.zone.now
    @validated_code_percentages = []
    initialize_first_code_percentages
  end

  def aggregate(call_characteristics)
    @current_call = call_characteristics
    return if outside_full_scope?
    move_to_next_http_code_percentage until in_scope?
    compute_aggregation
  end

  def as_json
    move_to_next_http_code_percentage until @code_percentages_durations.empty?
    {
      'http_code_percentages': @validated_code_percentages.as_json.reduce({}, :merge)
    }
  end

  private

  def outside_full_scope?
    @current_call.timestamp < (@now - @max_duration)
  end

  def in_scope?
    current_code_percentage.in_scope?(@current_call.timestamp)
  end

  def initialize_first_code_percentages
    @validated_code_percentages << Stats::HttpCodePercentages.new(
      scope_duration: @code_percentages_durations.shift,
      beginning_time: @now
    )
  end

  def move_to_next_http_code_percentage
    next_code_percentage = current_code_percentage.dup
    next_code_percentage.scope_duration = @code_percentages_durations.shift
    @validated_code_percentages << next_code_percentage
  end

  def current_code_percentage
    @validated_code_percentages.last
  end

  def compute_aggregation
    current_code_percentage.add(@current_call)
  end
end
