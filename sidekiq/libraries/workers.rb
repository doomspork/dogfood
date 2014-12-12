module Sidekiq
  module Helpers
    def workers
      @workers ||= node[:sidekiq][application].to_hash.reject {|k,v| k.to_s =~ /restart_command|syslog/ }
    end
  end
end

Chef::Recipe.send(:include, Sidekiq::Helpers)
