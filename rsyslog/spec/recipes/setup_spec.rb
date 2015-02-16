require 'chefspec'

describe 'rsyslog::setup' do
  let(:remotes) { { 'Test' => { 'url' => '@@tcp.example.com:1337' } } }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['rsyslog']['remotes'] = remotes
    end.converge(described_recipe)
  end

  it 'creates a conf file with defaults' do
    expect(chef_run).to create_template('/etc/rsyslog.d/Test.conf')
    expect(chef_run).to render_file('/etc/rsyslog.d/Test.conf').with_content('*.* @@tcp.example.com:1337')
  end

  context 'with selector filter' do
    before { remotes['Test'].merge!('filters' => { 'selector' => '*.warn' }) }

    it 'creates a conf file with given selector' do
      expect(chef_run).to render_file('/etc/rsyslog.d/Test.conf').with_content('*.warn @@tcp.example.com:1337')
    end
  end

  context 'with property filters' do
    let(:remotes) { { 'Test' => { 'filters' => { 'property' => [':syslogtag, !contains, "unimportantapp" ~'] }, 'url' => '@@tcp.example.com:1337' } } }

    it 'creates a conf giles with property filters' do
      expect(chef_run).to render_file('/etc/rsyslog.d/Test.conf').with_content(':syslogtag, !contains, "unimportantapp')
    end
  end

  context 'with many remotes' do
    let(:remotes) { { 'Test' => { 'url' => '@@tcp.example.com:1337' }, 'foo' => { 'url' => '@udp.example.com:1337' } } }

    it 'creates a rsyslog conf file' do
      expect(chef_run).to create_template('/etc/rsyslog.d/Test.conf')
      expect(chef_run).to create_template('/etc/rsyslog.d/foo.conf')
    end
  end
end
