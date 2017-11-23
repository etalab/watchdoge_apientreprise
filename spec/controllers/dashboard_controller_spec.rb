require 'rails_helper'

describe DashboardController, type: :controller do
  describe 'Current status happy path', vcr: { cassette_name: 'current_status' } do
    subject { get :current_status }

    it 'returns 200' do
      expect(subject.status).to eq(200)
    end

    it 'returns well formated json' do
      json = JSON.parse(subject.body)
      expect(json).to be_a(Hash)

      json['results'].each do |e|
        expect(e['name']).not_to be_empty
        expect(e['code']).to be_a(Integer)
      end
    end
  end
end
