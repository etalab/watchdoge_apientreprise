class Availabilities
  def initialize
    @availabilities = []
  end

  def add_ping(code, time)
    @code = code
    @time = time

    return false unless valid?

    add_or_update
    true
  end

  def sla
    ((1.0 - down_duration / full_range_duration) * 100).round(2)
  end

  def to_a
    @availabilities
  end

  private

  def valid?
    valid_code? && valid_time?
  end

  def valid_code?
    [0, 1].include?(@code)
  end

  def valid_time?
    @time =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/
  end

  def add_or_update
    if @availabilities.size.zero?
      add_new_availability
    else
      update_last_availability
    end
  end

  def add_new_availability
    @availabilities << [
      @time,
      @code,
      @time
    ]
  end

  def update_last_availability
    last_availability[2] = @time

    add_new_availability if different_code?
  end

  def different_code?
    last_status_code != @code
  end

  def last_status_code
    last_availability[1]
  end

  def last_availability
    @availabilities.last
  end

  def full_range_duration
    from = Time.parse(@availabilities.first.first)
    to = Time.parse(@availabilities.last.last)

    interval_to_seconds(to - from)
  end

  def down_duration
    down_time = @availabilities.map do |d|
      next if d[1] == 1 # means it's UP
      from = Time.parse(d[0])
      to = Time.parse(d[2])
      interval_to_seconds(to - from)
    end

    down_time.compact.inject(0, :+)
  end

  def interval_to_seconds(interval)
    (interval * 24 * 60 * 60).to_f
  end
end
