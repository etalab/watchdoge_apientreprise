require 'rails_helper'

# rubocop:disable RSpec/MultipleDescribes
describe 'watch:period_1', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 3 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(3).to(0)
    end
  end
end

describe 'watch:period_5', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 4 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(4).to(0)
    end
  end
end

describe 'watch:period_15', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 1 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(1).to(0)
    end
  end
end

describe 'watch:period_60', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 21 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(21).to(0)
    end
  end
end
# rubocop:enable RSpec/MultipleDescribes
