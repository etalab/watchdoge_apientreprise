require 'rails_helper'

describe 'refill_database' do
  include_context 'rake'

  it 'refill the database' do
    task.invoke
    expect(Endpoint.all.count).to eq(endpoints_count)
  end

  it 'call refill_database' do
    expect_any_instance_of(Tools::EndpointDatabaseFiller).to receive(:refill_database).once
    task.invoke
  end
end
