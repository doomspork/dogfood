# Adapted from unicorn::rails: https://github.com/aws/opsworks-cookbooks/blob/master/unicorn/recipes/rails.rb

include_recipe "opsworks_sidekiq::service"

# setup sidekiq service per app
node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping opsworks_sidekiq::setup application #{application} as it is not a Rails app")
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
    source "sudoer.erb"
    variables :user => deploy[:user]
  end

  if node[:sidekiq][application]
    workers = node[:sidekiq][application].to_hash.reject {|k,v| k.to_s =~ /restart_command|syslog/ }
    config_directory = "#{deploy[:deploy_to]}/shared/config"

    unless workers.empty?
      workers.each do |worker, options|

        # Convert attribute classes to plain old ruby objects
        config = options[:config] ? options[:config].to_hash : {}

        (options[:process_count] || 1).times do |n|
          template "#{config_directory}/sidekiq_#{worker}#{n+1}.yml" do
            owner node[:owner_name]
            group node[:owner_name]
            mode 0644
            source "sidekiq.yml.erb"
            variables config
          end
        end
      end

      template "/etc/monit.d/sidekiq_#{application}.monitrc" do
        mode 0644
        source "sidekiq_monitrc.erb"
        variables({
          :application => application,
          :deploy      => deploy,
          :environment => OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables]),
          :syslog      => node[:sidekiq][application][:syslog],
          :workers     => workers
        })
        notifies :reload, "service[monit]", :delayed
      end

    end
  end
end
