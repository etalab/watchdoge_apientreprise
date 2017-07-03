require 'rails_helper'

describe TestJob, type: :job do
  it 'is true' do
    t = true
    expect(t).to be_truthy
  end
end
