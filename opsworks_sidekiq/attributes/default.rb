include_attribute 'deploy'

default[:sidekiq] = {}

node[:deploy].each do |application, deploy|
  default[:sidekiq][application] ||= {}
  default[:sidekiq][application][:restart_command] = "sudo monit restart -g sidekiq_#{application}_group"
  default[:sidekiq][application][:syslog] = false
end
