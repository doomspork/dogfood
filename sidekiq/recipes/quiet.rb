node['sidekiq'].each do |application, _|
  execute "quiet Sidekiq #{application}" do
    action :run
  end
end
