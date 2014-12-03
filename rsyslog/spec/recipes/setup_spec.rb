require 'chefspec'

describe 'rsyslog::setup' do
  let(:remotes) { { 'Test' => '@@tcp.example.com:1337' } }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['rsyslog']['remotes'] = remotes
    end.converge(described_recipe)
  end

  it 'creates a rsyslog conf file' do
    expect(chef_run).to create_template('/etc/rsyslog.d/Test.conf')
  end

  context 'with many remotes' do
    let(:remotes) { { 'Test' => '@@tcp.example.com:1337', 'foo' => '@udp.example.com:1337' } }

    it 'creates a rsyslog conf file' do
      expect(chef_run).to create_template('/etc/rsyslog.d/Test.conf')
      expect(chef_run).to create_template('/etc/rsyslog.d/foo.conf')
    end
  end
end
