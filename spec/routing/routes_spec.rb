require 'rails_helper'

describe 'routes', :type => :routing do
  it 'route to current status' do
    expect(get('dashboard/current_status')).to route_to(controller: 'dashboard', action: 'current_status')
  end

  it 'route to history' do
    expect(get('dashboard/availability_history')).to route_to(controller: 'dashboard', action: 'availability_history')
  end
end
