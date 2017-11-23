require 'rails_helper'

describe 'Elk queries' do
    it 'should be a JSON file' do
      data = File.read('app/data/queries/current_status.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end

    it 'should be a JSON file' do
      data = File.read('app/data/queries/availability_history.json')
      json = JSON.parse(data)
      expect(json.class).to be(Hash)
    end
end
