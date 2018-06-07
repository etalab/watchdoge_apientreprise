require 'rails_helper'

describe 'routes', type: :routing do
  it 'route to current status' do
    expect(get('api/watchdoge/dashboard/current_status')).to route_to(controller: 'dashboard', action: 'current_status')
  end

  it 'route to history' do
    expect(get('api/watchdoge/dashboard/availability_history')).to route_to(controller: 'dashboard', action: 'availability_history')
  end

  it 'route to homepage status' do
    expect(get('api/watchdoge/dashboard/homepage_status')).to route_to(controller: 'dashboard', action: 'homepage_status')
  end

  it 'route to jwt_usage stats' do
    expect(get("api/watchdoge/stats/jwt_usage/#{JwtHelper.api(:valid)}")).to route_to(controller: 'stats', action: 'jwt_usage', jwt: JwtHelper.api(:valid))
  end

  it 'route to last_30_days_usage' do
    expect(get('api/watchdoge/stats/last_30_days_usage/')).to route_to(controller: 'stats', action: 'last_30_days_usage')
  end
end
