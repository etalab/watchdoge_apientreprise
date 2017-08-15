class HTTPResponseValidator < ActiveModel::Validator
  def validate(record)
    @ping = record
    unless response_regeneration_mode || valid?
      offending_keys = @diff.map { |e| e[1] }.join(' ')
      record.errors.add(:http_response, "json response is not as expected! (#{offending_keys})")
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

    clean_diff unless @ping.response_regexp.nil?

    @diff.empty?
  end

  def clean_diff
    @diff.delete_if do |diff|
      valid_json_element = false
      # diff format: [['~/+/-', 'key name', 'first value', 'second value'], ...]
      type = diff[0]
      offending_key = diff[1]
      value_body = diff[2].to_s
      value_expected = diff[3].to_s

      if type == '~'
        regexp = ping_regexp_for offending_key
        if regexp && value_body =~ regexp && value_expected =~ regexp
          valid_json_element = true
        end
      end

      valid_json_element
    end
  end

  def ping_regexp_for key
    regexp_str = @ping.response_regexp.find { |elt| elt['name'] == key }['regexp']
    return if regexp_str.nil?
    Regexp.new regexp_str
  end

  # re-evaluated in rake task watch:store_responses
  def response_regeneration_mode
    false
  end
end
