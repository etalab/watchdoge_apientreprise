RSpec.shared_examples 'logstashable' do
  subject { described_class.new }
  let(:value) { 'this is a value' }
  let(:another_value) { 'this is another value' }

  before do
    subject.logger.info({
      rspec: value,
      another_rspec: another_value
    })
  end

  it 'writes in file in logstash format' do
    filename = described_class.send(:logfile)
    last_line = File.readlines(filename).last
    json = JSON.parse(last_line)

    expect(json).to include_json(
      msg: 'ping',
      rspec: value,
      another_rspec: another_value
    )

    File.truncate(filename, 0)
  end
end
