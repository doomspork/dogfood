include_recipe 'sidekiq::service'

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::restart for #{application}, not configured for Sidekiq.")
    next
  end

  execute "restart Sidekiq [#{application}]" do
    command "sudo monit restart -g sidekiq_#{application}_group"
  end
end

