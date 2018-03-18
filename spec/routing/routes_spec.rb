require 'rails_helper'

describe 'routes', type: :routing do
  it 'route to current status' do
    expect(get('dashboard/current_status')).to route_to(controller: 'dashboard', action: 'current_status')
  end

  it 'route to history' do
    expect(get('dashboard/availability_history')).to route_to(controller: 'dashboard', action: 'availability_history')
  end

  it 'route to homepage status' do
    expect(get('dashboard/homepage_status')).to route_to(controller: 'dashboard', action: 'homepage_status')
  end

  it 'route to jwt_usage stats' do
    expect(get("stats/jwt_usage/#{valid_jti}")).to route_to(controller: 'stats', action: 'jwt_usage', jti: valid_jti)
  end
end
