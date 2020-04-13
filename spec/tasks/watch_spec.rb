require 'rails_helper'

# rubocop:disable RSpec/MultipleDescribes
describe 'watch:period_1', vcr: { cassette_name: 'all_APIs' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    let(:nb_apis) { Endpoint.where(ping_period: 1).size }

    it 'send exactly ping_period: 1 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(nb_apis).to(0)
    end
  end
end

describe 'watch:period_5', vcr: { cassette_name: 'all_APIs' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    let(:nb_apis) { Endpoint.where(ping_period: 5).size }

    it 'send exactly ping_period: 5 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(nb_apis).to(0)
    end
  end
end

describe 'watch:period_15', vcr: { cassette_name: 'all_APIs' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    let(:nb_apis) { Endpoint.where(ping_period: 15).size }

    it 'send exactly ping_period: 15 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(nb_apis).to(0)
    end
  end
end

describe 'watch:period_60', vcr: { cassette_name: 'all_APIs' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    let(:nb_apis) { Endpoint.where(ping_period: 60).size }

    it 'send exactly ping_period: 60 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(nb_apis).to(0)
    end
  end
end

describe 'watch:period_150', vcr: { cassette_name: 'all_APIs' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    let(:nb_apis) { Endpoint.where(ping_period: 150).size }

    pending 'send exactly ping_period: 150 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(nb_apis).to(0)
    end
  end
end

# rubocop:enable RSpec/MultipleDescribes
