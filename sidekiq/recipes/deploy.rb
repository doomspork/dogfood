include_recipe 'deploy'
include_recipe 'sidekiq::quiet'

node['sidekiq'].each do |application, _|
  deploy = node['deploy'][application]

  opsworks_deploy_dir do
    user deploy['user']
    group deploy['group']
    path deploy['deploy_to']
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end

include_recipe 'sidekiq::restart'
