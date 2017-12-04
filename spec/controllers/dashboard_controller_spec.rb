require 'rails_helper'

describe DashboardController, type: :controller do
  describe 'Current status happy path', vcr: { cassette_name: 'current_status' } do
    subject { get :current_status }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('current_status') }
  end

  describe 'Homepage status happy path', vcr: { cassette_name: 'homepage_status' } do
    subject { get :homepage_status }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('homepage_status') }
  end

  describe 'Availability history status happy path', vcr: { cassette_name: 'availability_history' } do
    subject(:response) { @availability_results_controller }

    before do
      remember_through_tests('availability_results_controller') do
        get :availability_history
      end
    end

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('availability_history') }

    # rubocop:disable RSpec/ExampleLength
    it 'availabilities have no gap and from < to' do
      json = JSON.parse(response.body)

      json['results'].each do |provider|
        provider['endpoints_history'].each do |ep|
          max_index = ep['availabilities'].size - 1
          index = 0
          previous_to_datetime = nil

          ep['availabilities'].each do |avail|
            if index < max_index
              # from < to (except for last one)
              expect(DateTime.parse(avail[0])).to be < DateTime.parse(avail[2])
              index = index + 1
            end

            # has no gap
            unless previous_to_datetime.nil?
              from_datetime = DateTime.parse(avail[0])
              expect(from_datetime).to eq(previous_to_datetime)
            end

            previous_to_datetime = DateTime.parse(avail[2])
          end
        end
      end
    end
  end
end
