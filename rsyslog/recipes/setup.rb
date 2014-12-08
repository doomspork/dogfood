node['rsyslog']['remotes'].each do |name, url|
  template "/etc/rsyslog.d/#{name}.conf" do
    mode 0644
    source 'rsyslog.conf.erb'
    variables remote: url
  end
end

service 'rsyslog' do
  action :restart
end
