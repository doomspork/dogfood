include_recipe 'deploy'
include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, _|
  deploy = node['deploy'][application]

  execute "quiet Sidekiq #{application}" do
    action :run
    notifies :run, "execute[unmonitor Sidekiq #{application}]", :immediately
  end

  opsworks_deploy_dir do
    user deploy['user']
    group deploy['group']
    path deploy['deploy_to']
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  service "Sidekiq #{application}" do
    action :restart
  end
end
