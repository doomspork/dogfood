service 'monit' do
  supports status: false, restart: true, reload: true
  action :nothing
end

node['sidekiq'].each do |application, config|
  execute "restart Rails app #{application}" do
    command config['restart_command']
    action :nothing
  end
end
