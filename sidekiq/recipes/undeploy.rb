node['sidekiq'].each do |application, _|
  deploy = node['deploy'][application]

  directory deploy['deploy_to'] do
    recursive true
    action :delete
    only_if { ::File.exists?(deploy['deploy_to']) }
  end
end
