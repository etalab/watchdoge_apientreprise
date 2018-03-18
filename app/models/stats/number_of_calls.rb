class Stats::NumberOfCalls
  def initialize
    @stats_intervals = [10.minutes, 30.hours, 8.days]
    @validated_stats_intervals = []
  end

  def aggregate(endpoint_ping_result)
    @current_ping_result = endpoint_ping_result
    next_interval if next_interval_reached?
    compute_aggregation
  end

  def to_json
    @validated_stats_intervals.to_json
  end

  private

  def current_stats_interval
    @validated_stats_intervals.last
  end

  def next_interval
    @validated_stats_intervals << StatsInterval.new(@stats_intervals.shift, @current_ping_result.timestamps)
  end

  def next_interval_reached?
    current_stats_interval.nil? || new_timestamp_outside_interval?
  end

  def new_timestamp_outside_interval?
    (@current_ping_result.timestamp - current_stats_interval.beginning_timestamp) > current_stats_interval.interval
  end

  def compute_aggregation
    current_stats_interval.aggregate(@current_ping_result)
  end
end