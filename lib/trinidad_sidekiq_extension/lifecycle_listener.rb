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
              STDOUT << "[Trinidad:Sidekiq] event [#{event.type}] << start >>\n" if options[:verbose]
              start_cli
            when Trinidad::Tomcat::Lifecycle::BEFORE_STOP_EVENT
              STDOUT << "[Trinidad:Sidekiq] event [#{event.type}] << stop >>\n" if options[:verbose]
              stop_cli
            else
              STDOUT << "[Trinidad:Sidekiq] event [#{event.type}] skipped\n" if options[:verbose]
          end
        end

        def start_cli
          STDOUT << "[Trinidad:Sidekiq] starting sidekiq bm with options [#{@options}]\n" if options[:verbose]
          unless options[:require]
            raise "You probably want to send a require option to the sidekiq background manager ..." if options[:verbose]
          end

          STDOUT << "[Trinidad:Sidekiq] getting it going ...\n"
          bm = ::Sidekiq::BackgroundManager.instance
          STDOUT << "[Trinidad:Sidekiq] got original bm (#{bm.class.name}) #{bm.inspect} ...\n" if options[:verbose]
          bm.configure @options
          STDOUT << "[Trinidad:Sidekiq] got modified bm (#{bm.class.name}) #{bm.inspect} ...\n" if options[:verbose]
          res = bm.run
          STDOUT << "[Trinidad:Sidekiq] got bm running (#{res.class.name}) #{res.inspect} ...\n" if options[:verbose]
        end

        def stop_cli
          STDOUT << "[Trinidad:Sidekiq] Stopping sidekiq cli ...\n" if options[:verbose]
          res = ::Sidekiq::BackgroundManager.instance.interrupt
          STDOUT << "[Trinidad:Sidekiq] got bm stopped (#{res.class.name})#{res.inspect} ...\n" if options[:verbose]
        end

      end
    end
  end
end
