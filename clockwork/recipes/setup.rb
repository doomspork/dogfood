service 'monit' do
  supports status: false, restart: true, reload: true
  action :nothing
end

application = node['clockwork']['application']
clock       = node['clockwork']['file'] || 'clock.rb'
deploy      = node['deploy'][application]
host        = node['clockwork']['hostname']
name        = node['clockwork']['name'] || application

execute 'clockwork-restart' do
  command "monit restart clockwork_#{name}"
  action :nothing
end

template "/etc/monit.d/clockwork_#{name}.monitrc" do
  mode 0644
  source 'clockwork_monitrc.erb'
  variables({
    clock: clock,
    deploy: deploy,
    environment: OpsWorks::Escape.escape_double_quotes(deploy['environment_variables']),
    name: "clockwork_#{name}"
  })
  notifies :reload, 'service[monit]', :immediately
  notifies :run, 'execute[clockwork-restart]', :delayed

  only_if { host == node['hostname'] }
end
