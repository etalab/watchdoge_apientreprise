require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
describe 'Elk queries' do
  context 'with current status' do
    it 'is a JSON file' do
      data = File.read('app/data/queries/current_status.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end
  end

  context 'with availability history' do
    it 'is a JSON file' do
      data = File.read('app/data/queries/availability_history.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end
  end

  context 'with homepage status' do
    it 'is a JSON file' do
      data = File.read('app/data/queries/homepage_status.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end
  end

  context 'with last 30 days usage' do
    it 'is a JSON file' do
      data = File.read('app/data/queries/last_30_days_usage.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
