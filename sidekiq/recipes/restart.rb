include_recipe 'deploy'

node['sidekiq'].each do |application, _|
  execute "restart Sidekiq [#{application}]" do
    command "sleep #{deploy['sleep_before_restart']} && sudo monit restart -g sidekiq_#{application}_group"
    only_if { ::File.exists?("/etc/monit.d/sidekiq_#{application}.monitrc") }
  end
end
