class HTTPResponseValidator < ActiveModel::Validator
  def validate(record)
    @ping = record
    unless response_regeneration_mode || valid?
      record.errors.add(:http_response, 'json response is not as expected! (#{@diff})')
    end
  end

  private

  def expected_json_response
    begin
      content = File.read(@ping.response_file)
      JSON.parse(content)
    rescue
      {}
    end
  end

  def valid?
    @diff = HashDiff.diff(@ping.json_response_body, expected_json_response)
    @diff.empty?
    # TODO: add option to HTTPResponseValidator with [(key, regexp),..] in order to remove from the diff:
    # ["~", "key[1]", "regexp_valid", " another_regexp_valid"]
    true
  end

  # re-evaluated in rake task watch:store_responses
  def response_regeneration_mode
    false
  end
end
