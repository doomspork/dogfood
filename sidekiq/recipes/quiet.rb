node[:deploy].each do |application, deploy|
  unless node[:sidekiq][application]
    Chef::Log.debug("Skipping sidekiq::quiet for #{application}, not configured for Sidekiq.")
    next
  end

  workers(application).each do |worker, options|
    processes = (options[:process_count] || 1)
    pid_dir   = "#{deploy[:deploy_to]}/shared/pids"

    processes.times do |n|
      identifier = "#{application}-#{worker}#{n+1}"
      pid_file   = File.join(pid_dir, "sidekiq_#{identifier}.pid")

      execute "quiet Sidekiq process [#{identifier}]" do
        cwd pid_dir
        command "if kill -0 `cat #{pid_file}` > /dev/null 2>&1; then kill -s USR1 `cat #{pid_file}`; fi"
        user deploy[:user]

        only_if { ::File.exists?(pid_file) }
      end

    end
  end
end
