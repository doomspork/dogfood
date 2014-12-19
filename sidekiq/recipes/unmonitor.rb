include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, _|
  execute "unmonitor Sidekiq #{application}" do
    action :run
  end
end
