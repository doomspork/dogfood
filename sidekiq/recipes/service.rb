service 'monit' do
  supports status: false, restart: true, reload: true
  action :nothing
end

node['sidekiq'].each do |application, config|
  deploy = node['deploy'][application]

  sleep_before_monit = 10

  service "Sidekiq #{application}" do
    supports status: false, reload: false, restart: true
    restart_command "sleep #{sleep_before_monit} && sudo monit restart -g sidekiq_#{application}_group"
    stop_command "sleep #{sleep_before_monit} && sudo monit stop -g sidekiq_#{application}_group"
    action :nothing
  end

  execute "unmonitor Sidekiq #{application}" do
    command "sleep #{sleep_before_monit} && sudo monit unmonitor -g sidekiq_#{application}_group"
    action :nothing
  end

  pid_dir = "#{deploy['deploy_to']}/shared/pids"
  sidekiq_processes = []
  configured_workers(config).each do |worker, opts|
    (opts['process_count'] || 1).times do |n|
      pid_file = File.join(pid_dir, "#{application}-#{worker}#{n+1}.pid")
      sidekiq_processes.push([pid_file, "if kill -0 `cat #{pid_file}` > /dev/null 2>&1; then kill -s USR1 `cat #{pid_file}`; fi"])
    end
  end

  execute "quiet Sidekiq #{application}" do
    cwd pid_dir
    command sidekiq_processes.map(&:last).join('&&')
    user deploy['user']
    action :nothing
  end
end
