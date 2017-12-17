class String
  def valid_json?
    JSON.parse(self)
    return true
  rescue JSON::ParserError
    return false
  end
end
