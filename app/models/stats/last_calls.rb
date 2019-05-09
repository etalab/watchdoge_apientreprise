class Stats::LastCalls
  LIMIT = 50

  CallAdapter = Struct.new(:call) do
    def as_json
      {
        uname: call.uname,
        name: call.name,
        url: call.http_path,
        params: call.params,
        code: call.code.to_i,
        timestamp: call.timestamp
      }
    end
  end

  def initialize
    @last_calls = []
    @count = 0
  end

  def add(call_result)
    return if @count >= LIMIT

    @last_calls << call_result
    @count += 1
  end

  def as_json
    @last_calls.map { |e| CallAdapter.new(e).as_json }
  end
end
