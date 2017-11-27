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
        expect(e['timestamp']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
      end
    end
  end

  describe 'Homepage status happy path', vcr: { cassette_name: 'homepage_status' } do
    subject { get :homepage_status }

    it 'returns 200' do
      expect(subject.status).to eq(200)
    end

    it 'returns well formated json' do
      json = JSON.parse(subject.body)
      expect(json).to be_a(Hash)

      expect(json.dig('results', 0, 'name')).not_to be_empty
      expect(json.dig('results', 0, 'code')).to be_a(Integer)
      expect(json.dig('results', 0, 'timestamp')).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
    end
  end

  describe 'Availability history status happy path', vcr: { cassette_name: 'availability_history' } do
    subject { get :availability_history }

    it 'returns 200' do
      expect(subject.status).to eq(200)
    end

    it 'returns well formated json' do
      json = JSON.parse(subject.body)
      expect(json).to be_a(Hash)

      json['results'].each do |e|
        expect(e['name']).not_to be_empty
        expect(e['sla']).to be_a(Float)
        e['availabilities'].each do |a|
          expect(a[0]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
          expect(a[1]).to be_in([0, 1])
          expect(a[2]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
        end
      end
    end
  end
end