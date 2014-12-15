include_recipe 'sidekiq::service'

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::unmonitor for #{application}, not configured for Sidekiq.")
    next
  end

  execute "unmonitor Sidekiq [#{application}]" do
    command "sudo monit unmonitor -g sidekiq_#{application}_group"
    only_if { ::File.exists?("/etc/monit.d/sidekiq_#{application}.monitrc") }
  end
end
