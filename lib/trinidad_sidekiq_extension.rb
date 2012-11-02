require 'trinidad'
require_relative "trinidad_sidekiq_extension/version"
require_relative "trinidad_sidekiq_extension/background_manager"
require_relative "trinidad_sidekiq_extension/lifecycle_listener"

module Trinidad
  module Extensions
    class SidekiqWebAppExtension < WebAppExtension
      def configure(app_context)
        app_context.add_lifecycle_listener Sidekiq::LifecycleListener.new(@options)
      end
    end
  end
end

