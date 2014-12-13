include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::setup for #{application}, not configured for Sidekiq.")
    next
  end

  directory deploy[:deploy_to] do
    recursive true
    action :delete
    only_if do
      File.exists?(deploy[:deploy_to])
    end
  end
end
