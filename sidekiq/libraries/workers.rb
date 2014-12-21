module Sidekiq
  module Helpers
    def configured_workers(config)
      @configured_workers ||= config.each_with_object({}) do |(k, v), memo|
        next if k.to_s =~ /restart_command|syslog/
        memo[k] = v
      end
    end
  end
end

Chef::Recipe.send(:include, Sidekiq::Helpers)
