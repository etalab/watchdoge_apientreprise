class PingReport < ApplicationRecord
  validates :uname, presence: true, uniqueness: true
  validates :last_code, numericality: { only_integer: true }, inclusion: { in: 200..599 }, allow_nil: true
  validate :first_downtime_class

  def notify_change(code)
    @new_code = code
    update_state
    save
    self
  end

  def changed?
    @changed || false
  end

  def status
    case last_code
    when 200
      'UP'
    when 206
      'INCOMPLETE'
    else
      'DOWN'
    end
  end

  private

  def update_state
    @changed = going_down? || going_up?
    self.first_downtime = Time.now if going_down?
    self.last_code = @new_code
  end

  def going_down?
    ![200, 206].include?(@new_code) && ([200, 206].include?(last_code) || last_code.nil?)
  end

  def going_up?
    [200, 206].include?(@new_code) && (![200, 206].include?(last_code) || last_code.nil?)
  end

  def first_downtime_class
    first_downtime.is_a?(ActiveSupport::TimeWithZone)
  end
end
