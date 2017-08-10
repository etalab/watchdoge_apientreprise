RSpec.shared_examples 'logstashable' do
  subject(:object) { described_class.new }

  let(:value) { 'this is a value' }
  let(:another_value) { 'this is another value' }
  let(:expected_json) do
    {
      msg: 'ping',
      rspec: value,
      another_rspec: another_value
    }
  end

  before do
    object.logger.info(
      rspec: value,
      another_rspec: another_value
    )
  end

  it 'writes in file in logstash format' do
    filename = described_class.send(:logfile)
    last_line = File.readlines(filename).last
    json = JSON.parse(last_line)

    expect(json).to include_json(expected_json)

    File.truncate(filename, 0)
  end
end
