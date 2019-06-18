require 'rails_helper'

describe 'Dashboard', type: :request, vcr: { cassette_name: 'dashboard/current_status' } do
  before { Rails.cache.clear }

  def current_cache
    Rails.cache.read 'Dashboard::CurrentStatusService'
  end

  let(:expected_cache_value) do
    {
      success: true,
      results: be_an(Array),
      errors: ''
    }
  end

  example 'cache is available after first call' do
    expect(current_cache).to be_nil
    get dashboard_current_status_path
    expect(current_cache).to include(expected_cache_value)
  end

  example 'cache is returned at the second call because service if not called twice' do
    expect_any_instance_of(Dashboard::CurrentStatusService)
      .to receive(:perform).once.and_call_original
    get dashboard_current_status_path
    get dashboard_current_status_path
  end

  example 'cache expires after 5 minutes' do
    get dashboard_current_status_path
    Timecop.travel Time.zone.now + 6.minutes
    expect(current_cache).to be_nil
  end
end
