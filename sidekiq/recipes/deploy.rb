include_recipe 'deploy'
include_recipe 'sidekiq::service'

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

  ruby_block "bundle Sidekiq #{application}" do
   block do
     OpsWorks::RailsConfiguration.bundle(application, deploy, "#{deploy[:deploy_to]}/current")
   end
  end
end
