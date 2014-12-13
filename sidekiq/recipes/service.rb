service 'monit' do
  supports status: false, restart: true, reload: true, unmonitor: true
  action :nothing
end

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::setup for #{application}, not configured for Sidekiq.")
    next
  end

  execute "restart Rails app #{application}" do
    command node[:sidekiq][application][:restart_command]
    action :nothing
  end
end
