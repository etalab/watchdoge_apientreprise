class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :url, :http_response

  def code
    http_response.code
  end

  def status
    case http_response.code
    when 200
      'up'
    when 206
      'incomplete'
    else
      'down'
    end
  end

  # for debugging purpose its unreadable with http_response on screen
  def inspect
    vars = instance_variables
           .map { |v| "#{v}=#{instance_variable_get(v).inspect}" unless %i[@http_response @url].include?(v) }
           .join(', ')
    "<#{self.class}: #{vars}, @status=#{status}>"
  end
end
