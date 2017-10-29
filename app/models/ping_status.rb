class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :http_response

  # if we want JSON validation : https://github.com/ruby-json-schema/json-schema

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
    .map { |v| "#{v}=#{instance_variable_get(v).inspect}" unless v == :@http_response }
    .join(', ')
    "<#{self.class}: #{vars}, @status=#{status}>"
  end
end
