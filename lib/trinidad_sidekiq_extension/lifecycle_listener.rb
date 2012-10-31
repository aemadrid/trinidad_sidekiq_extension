require "sidekiq"
require "sidekiq/cli"

module Trinidad
  module Extensions
    module Sidekiq
      class LifecycleListener
        include Trinidad::Tomcat::LifecycleListener
        attr_accessor :options, :workers, :threads

        def initialize(options = { })
          @options = options || {}
        end

        def lifecycleEvent(event)
          case event.type
            when Trinidad::Tomcat::Lifecycle::AFTER_START_EVENT
              start_cli
            when Trinidad::Tomcat::Lifecycle::BEFORE_STOP_EVENT
              stop_cli
          end
        end

        def cli

        end

        def start_cli
          arguments = (@options[:arguments] || @options['arguments']).to_s.strip
          puts ">> starting sidekiq cli with arguments [#{arguments}] ..."
          if arguments.empty?
            raise "You probably want to send some arguments to the sidekiq cli"
          end

          puts ">> got original cli (#{cli.class.name}) #{cli.inspect} ..."
          cli.parse arguments.split(" ")
          puts ">> got modified cli (#{cli.class.name}) #{cli.inspect} ..."
          res = cli.run
          puts ">> got cli running (#{res.class.name}) #{res.inspect} ..."
        end

        def stop_cli
          puts "Stopping sidekiq cli ..."
          res = cli.interrupt
          puts ">> got cli stopped (#{res.class.name})#{res.inspect} ..."
        end

      end
    end
  end
end
