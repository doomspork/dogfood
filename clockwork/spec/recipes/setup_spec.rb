require 'chefspec'

describe 'clockwork::setup' do
  let(:application) { 'example_application' }
  let(:file)        { 'different_clockfile.rb' }
  let(:hostname)    { 'chefspec' } # Pre-populated by Chefspec
  let(:name)        { 'example_scheduling' }

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['clockwork']['application'] = application
      node.set['clockwork']['file']        = file
      node.set['clockwork']['hostname']    = hostname
      node.set['clockwork']['name']        = name
      node.set['deploy'][application]      = {}
    end.converge(described_recipe)
  end

  it 'creates a monitrc conf file' do
    path = "/etc/monit.d/clockwork_#{name}.monitrc"
    template = chef_run.template(path)

    expect(chef_run).to create_template(path).with(
      variables: {
        clock: file,
        deploy: {},
        name: "clockwork_#{name}"
      }
    )
    expect(template).to notify('service[monit]').to(:reload).immediately
    expect(template).to notify('execute[clockwork-restart]').to(:run).delayed
  end

  context 'with defaults' do
    let(:file) { nil }
    let(:name) { nil }

    it 'creates a monitrc conf file' do
      path = "/etc/monit.d/clockwork_#{application}.monitrc"
      expect(chef_run).to create_template(path).with(
        variables: {
          clock: 'clock.rb',
          deploy: {},
          name: "clockwork_#{application}"
        }
      )
    end
  end

  context 'with different host' do
    let(:desired_host)  { 'another_host' }

    it 'will not create a monitrc conf file' do
      path = "/etc/monit.d/clockwork_#{application}.monitrc"
      expect(chef_run).not_to create_template(path)
    end
  end
end
