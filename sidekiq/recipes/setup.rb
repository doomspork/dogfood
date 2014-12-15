include_recipe 'sidekiq::service'

# setup sidekiq service per app
node[:deploy].each do |application, deploy|
  Chef::Log.info(node[:sidekiq].inspect)
  if node[:sidekiq][application]
    Chef::Log.info("Skipping opsworks_sidekiq::setup for #{application}, not configured for Sidekiq.")
    next
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  # Allow deploy user to restart workers
  template "/etc/sudoers.d/#{deploy[:user]}" do
    mode 0440
    source 'sudoer.erb'
    variables :user => deploy[:user]
  end

  config_directory = "#{deploy[:deploy_to]}/shared/config"

  unless (workers = workers(application)).empty?
    Chef::Log.info("Generating configuration and monitrc for #{workers} processes.")
    # Stop any processes that might be running before we setup
    include_recipe 'sidekiq::stop'

    workers.each do |worker, options|

      # Convert attribute classes to plain old ruby objects
      config = options[:config] ? options[:config].to_hash : {}

      (options[:process_count] || 1).times do |n|
        template "#{config_directory}/sidekiq_#{worker}#{n+1}.yml" do
          owner node[:owner_name]
          group node[:owner_name]
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
        environment:  OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables]),
        syslog:       node[:sidekiq][application][:syslog],
        workers:      workers
      })
      notifies :reload, 'service[monit]', :delayed
    end

  end
end
