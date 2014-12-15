include_recipe 'sidekiq::service'

node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::stop for #{application}, not configured for Sidekiq.")
    next
  end

  include_recipe 'sidekiq::quiet'

  execute "stop Sidekiq [#{application}]" do
    command "sudo monit stop -g sidekiq_#{application}_group"
    only_if { ::File.exists?("/etc/monit.d/sidekiq_#{application}.monitrc") }
  end
end
