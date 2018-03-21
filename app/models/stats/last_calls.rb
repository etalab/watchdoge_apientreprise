class Stats::LastCalls
  LIMIT = 50

  CallAdapter = Struct.new(:call) do
    def as_json
      {
        uname: call.uname,
        name: call.name,
        path: call.http_path,
        params: call.params,
        timestamp: call.timestamp
      }
    end
  end

  def initialize
    @last_calls = []
    @count = 0
  end

  def add(call_characteristics)
    return if @count >= LIMIT
    @last_calls << call_characteristics
    @count += 1
  end

  def as_json
    binding.pry
    {
      last_calls: @last_calls.as_json
    }
  end
end