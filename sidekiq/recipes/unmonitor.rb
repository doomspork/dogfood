node['sidekiq'].each do |application, _|
  execute "unmonitor Sidekiq [#{application}]" do
    command "sudo monit unmonitor -g sidekiq_#{application}_group"
    only_if { ::File.exists?("/etc/monit.d/sidekiq_#{application}.monitrc") }
  end
end
