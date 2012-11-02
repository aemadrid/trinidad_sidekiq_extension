$stdout.sync = true

require 'yaml'
require 'singleton'
require 'optparse'
require 'celluloid'
require 'erb'

require 'sidekiq'
require 'sidekiq/util'
require 'sidekiq/manager'
require 'sidekiq/scheduled'

module Sidekiq
  class BackgroundManager
    include Util
    include Singleton

    # Used for BM testing
    attr_accessor :code
    attr_accessor :manager
    attr_reader :interrupted

    def initialize
      @code            = nil
      @interrupt_mutex = Mutex.new
      @interrupted     = false
    end

    def configure(given_options = { })
      @code = nil
      Sidekiq.logger

      logger.debug "BM configure : options : #{options.inspect}" if options[:verbose]
      logger.debug "BM configure : given_options : #{given_options.inspect}" if options[:verbose]
      config_options = parse_config given_options
      logger.debug "BM configure : config_options : #{config_options.inspect}" if options[:verbose]
      options.merge! config_options
      logger.debug "BM configure : options : #{options.inspect}" if options[:verbose]

      Sidekiq.logger.level = Logger::DEBUG if options[:verbose]
      Celluloid.logger = nil unless options[:verbose]

      validate!
      boot_system
    end

    def run
      logger.debug "Booting Sidekiq BM #{Sidekiq::VERSION} with Redis at #{redis { |x| x.client.id }}"
      logger.debug "Running in #{RUBY_DESCRIPTION}"
      logger.debug "Dir.pwd : #{Dir.pwd}"
      logger.debug Sidekiq::LICENSE

      @manager = Sidekiq::Manager.new(options)
      poller   = Sidekiq::Scheduled::Poller.new
      begin
        logger.debug 'BM Starting processing ...'
        @manager.start!
        poller.poll!(true)
        sleep
      rescue Interrupt
        logger.debug 'BM Shutting down ...'
        poller.terminate! if poller.alive?
        @manager.stop!(:shutdown => true, :timeout => options[:timeout])
        @manager.wait(:shutdown)
        # WILL NOT explicitly exit because Trinidad will take care of exiting
        # in its own sweet time.
        # exit(0)
      end
    end

    def interrupt
      @interrupt_mutex.synchronize do
        unless @interrupted
          logger.debug "BM interrupting ..."
          @interrupted = true
          Thread.main.raise Interrupt
        end
      end
    end

    private

    def die(code)
      exit(code)
    end

    def options
      Sidekiq.options
    end

    def detected_environment
      options[:environment] ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def boot_system
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = detected_environment

      raise ArgumentError, "#{options[:require]} does not exist" unless File.exist?(options[:require])

      logger.debug "BM Booting system with require [#{options[:require]}] ..."
      if File.directory?(options[:require])
        logger.debug "BM require [#{options[:require]}] is a directory, loading Rails ..."
        begin
          require 'rails'
          require 'sidekiq/rails'
          logger.debug "BM requiring #{options[:require]} ..."
          require File.expand_path("#{options[:require]}/config/environment.rb")
          ::Rails.application.eager_load!
        rescue LoadError => e
          logger.debug "EXCEPTION: #{e.class.name} : #{e.message}"
          logger.debug "We could not load rails, you will run into trouble!"
          raise "BM Could not load rails for require [#{options[:require]}], exiting ..."
        end
      else
        logger.debug "BM require [#{options[:require]}] is NOT a directory, requiring file ..."
        require options[:require]
      end
    end

    def validate!
      options[:queues] << 'default' if options[:queues].empty?

      if !File.exist?(options[:require]) ||
        (File.directory?(options[:require]) && !File.exist?("#{options[:require]}/config/application.rb"))
        logger.info "=================================================================="
        logger.info "  Please point sidekiq to a Rails 3 application or a Ruby file    "
        logger.info "  to load your worker classes with options[:require]= [DIR|FILE]. "
        logger.info "=================================================================="
        logger.info "options : #{options.inspect}"
        die(1)
      end
    end

    def parse_config(given_options)
      if given_options[:config_file] && File.exist?(given_options[:config_file])
        opts   = YAML.load(ERB.new(IO.read(given_options[:config_file])).result)
        queues = opts.delete(:queues) || []
        queues.each { |name, weight| parse_queues(opts, name, weight) }
        given_options.update opts
      end
      given_options
    end

    def parse_queues(opts, q, weight)
      [weight.to_i, 1].max.times do
        (opts[:queues] ||= []) << q
      end
    end

  end
end
