require 'rails_helper'

describe 'Dashboard', type: :request do
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

  example 'cache is available after first call', vcr: { cassette_name: 'dashboard/current_status' } do
    expect(current_cache).to be_nil
    get dashboard_current_status_path
    expect(current_cache).to include(expected_cache_value)
  end
end
