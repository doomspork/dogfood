include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::setup for #{application}, not configured for Sidekiq.")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  include_recipe 'sidekiq::setup'

  node.set[:opsworks][:rails_stack][:restart_command] = node[:sidekiq][application][:restart_command]

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end
