include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, _|
  service "Sidekiq #{application}" do
    action :restart
  end
end
