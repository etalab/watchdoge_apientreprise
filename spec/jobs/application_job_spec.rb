require 'rails_helper'

describe ApplicationJob, type: :job do
  it_behaves_like 'logstashed_ping'
end
