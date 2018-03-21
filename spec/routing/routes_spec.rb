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
end
