include_recipe 'deploy'
include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, _|
  deploy = node['deploy'][application]
  deploy_to = deploy['deploy_to']

  node.default['deploy'][application]['database']['adapter'] = OpsWorks::RailsConfiguration.determine_database_adapter(application, deploy, "#{deploy_to}/current", :force => node['force_database_adapter_detection'])

  template "#{deploy_to}/shared/config/database.yml" do
    source 'database.yml.erb'
    cookbook 'rails'
    mode '0660'
    group deploy['group']
    owner deploy['user']
    variables(:database => deploy['database'], :environment => deploy['rails_env'])

    only_if do
      File.exists?(deploy_to) && File.exists?("#{deploy_to}/shared/config/")
    end

    notifies :restart, "service[Sidekiq #{application}]", :delayed
  end
end
