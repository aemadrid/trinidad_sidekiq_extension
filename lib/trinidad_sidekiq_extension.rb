require 'sidekiq'
require 'trinidad'
require_relative "trinidad_sidekiq_extension/version"
require_relative "trinidad_sidekiq_extension/lifecycle_listener"

module Trinidad
  module Extensions
    class ThreadedSidekiqWebAppExtension < WebAppExtension
      def configure(_, app_context)
        app_context.add_lifecycle_listener(Sidekiq::LifecycleListener.new(@options))
      end
    end
  end
end

