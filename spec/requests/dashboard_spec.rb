require 'rails_helper'

describe 'Dashboard', type: :request do
  before { Rails.cache.clear }

  example 'second response comes from cache', vcr: { cassette_name: 'dashboard/current_status' } do
    expect_any_instance_of(Dashboard::CurrentStatusService)
      .to receive(:perform).once.and_call_original

    get dashboard_current_status_path
    get dashboard_current_status_path
  end
end
