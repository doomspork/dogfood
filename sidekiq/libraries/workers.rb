module Sidekiq
  module Helpers
    def workers(app)
      @workers ||= node[:sidekiq][app].to_hash.reject {|k,v| k.to_s =~ /restart_command|syslog/ }
    end
  end
end

Chef::Recipe.send(:include, Sidekiq::Helpers)
