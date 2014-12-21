include_recipe 'sidekiq::service'

node['sidekiq'].each do |application, config|
  deploy = node['deploy'][application]

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy['user']
    group deploy['group']
    path deploy['deploy_to']
  end

  # Allow deploy user to restart workers
  template "/etc/sudoers.d/#{deploy['user']}" do
    mode 0440
    source 'sudoer.erb'
    variables :user => deploy['user']
  end

  config_directory = "#{deploy['deploy_to']}/shared/config"

  workers = configured_workers(config)
  workers.each do |worker, options|
    # Convert attribute classes to plain old ruby objects
    config = options['config'] ? options['config'].to_hash : {}

    (options[:process_count] || 1).times do |n|
      template "#{config_directory}/sidekiq_#{worker}#{n+1}.yml" do
        owner node['owner_name']
        group node['owner_name']
        mode 0644
        source 'sidekiq.yml.erb'
        variables config
      end
    end
  end

  template "/etc/monit.d/sidekiq_#{application}.monitrc" do
    mode 0644
    source 'sidekiq_monitrc.erb'
    variables({
      application:  application,
      deploy:       deploy,
      environment:  OpsWorks::Escape.escape_double_quotes(deploy['environment_variables']),
      syslog:       config['syslog'] || false,
      workers:      workers
    })
    notifies :reload, 'service[monit]', :immediately
  end

end
