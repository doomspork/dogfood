DEFAULT_FILTERS = {
  'selector' => '*.*',
  'property' => []
}

node['rsyslog']['remotes'].each do |name, options|
  url = options['url']
  filters = DEFAULT_FILTERS.merge(options['filters'] || {})

  template "/etc/rsyslog.d/#{name}.conf" do
    mode 0644
    source 'rsyslog.conf.erb'
    variables filters: filters, remote: url
  end
end

service 'rsyslog' do
  action :restart
end
