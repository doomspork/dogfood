module Sidekiq
  module Helpers
    def configured_workers(config)
      @configured_workers ||= config.to_hash.reject { |k, v| k.to_s =~ /restart_command|syslog/ }
    end
  end
end

Chef::Recipe.send(:include, Sidekiq::Helpers)
