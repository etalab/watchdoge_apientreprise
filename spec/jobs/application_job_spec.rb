require 'rails_helper'

describe ApplicationJob, type: :job do
  it_behaves_like 'logstashable'
end
