template '/etc/rsyslog.d/splunk_storm.conf' do
  mode 0644
  source 'splunk_storm_conf.erb'
  variables node['splunk']
end

service 'rsyslog' do
  action :reload
end
