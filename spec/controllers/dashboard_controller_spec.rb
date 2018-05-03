require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable
describe DashboardController, type: :controller do
  describe 'Current status happy path', vcr: { cassette_name: 'dashboard/current_status' } do
    subject { get :current_status }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('dashboard/current_status') }
  end

  describe 'Homepage status happy path', vcr: { cassette_name: 'dashboard/homepage_status' } do
    subject { get :homepage_status }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('dashboard/homepage_status') }
  end

  describe 'Availability history status happy path LONG', very_long_test: true, vcr: { cassette_name: 'dashboard/availability_history' } do
    subject(:service_response) { @availability_results_controller }

    before do
      remember_through_tests('availability_results_controller') do
        get :availability_history
      end
    end

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('dashboard/availability_history') }

    it 'has no gap and from < to' do
      json = JSON.parse(service_response.body)
      expect(json['results']).to be_a_valid_availabilities_history
    end
  end

  describe 'Availability history status happy path SHORT', vcr: { cassette_name: 'dashboard/availability_history_shortened' } do
    subject(:service_response) { @availability_results_controller }

    before do
      allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:query_name).and_return('availability_history_shortened')
      remember_through_tests('availability_results_controller') do
        get :availability_history
      end
    end

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('dashboard/availability_history') }

    it 'has no gap and from < to' do
      json = JSON.parse(service_response.body)
      expect(json['results']).to be_a_valid_availabilities_history
    end
  end

  describe 'Availability History returns empty response' do
    subject { get :availability_history }

    before do
      # All this is because I cannot easly generate and stub response for this situation (that should never happened btw)
      allow_any_instance_of(ElasticClient).to receive(:establish_connection)
      allow_any_instance_of(ElasticClient).to receive(:connected?).and_return(true)
      allow_any_instance_of(ElasticClient).to receive(:search)
      allow_any_instance_of(ElasticClient).to receive(:success?).and_return(true)
      allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:retrieved_hits).and_return([]) # empty elk response
    end

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('dashboard/availability_history') }
  end

  describe 'Current status error path', vcr: { cassette_name: 'dashboard/current_status' } do
    subject { get :current_status }

    before { allow_any_instance_of(Dashboard::CurrentStatusService).to receive(:success?).and_return(false) }

    its(:status) { is_expected.to eq(500) }
  end

  describe 'Homepage status error path', vcr: { cassette_name: 'dashboard/homepage_status' } do
    subject { get :homepage_status }

    before { allow_any_instance_of(Dashboard::HomepageStatusService).to receive(:success?).and_return(false) }

    its(:status) { is_expected.to eq(500) }
  end

  describe 'Availability History error path', vcr: { cassette_name: 'dashboard/availability_history_shortened' } do
    subject { get :availability_history }

    before do
      allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:query_name).and_return('availability_history_shortened')
      allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:success?).and_return(false)
    end

    its(:status) { is_expected.to eq(500) }
  end
end
# rubocop:enable RSpec/InstanceVariable
