require 'chefspec'

describe 'splunk_storm::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'does something' do
    expect(chef_run).to create_template('/etc/rsyslog.d/splunk_storm.conf')
  end
end
