include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, _|
  execute "stop Sidekiq [#{application}]" do
    command "sudo monit stop -g sidekiq_#{application}_group"
    only_if { ::File.exists?("/etc/monit.d/sidekiq_#{application}.monitrc") }
  end
end
