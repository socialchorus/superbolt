module Superbolt
  class Config
    attr_reader :options
    attr_writer :app_name, :env

    def initialize(options={})
      @options = options
    end

    def app_name
      @app_name ||= options[:app_name]
    end

    def env
      @env ||= options[:env]
    end

    def connection_params
      env_params || default
    end

    def env_connection_key
      options[:connection_key] || 'RABBITMQ_URL'
    end

    def runner
      options[:runner]
    end

    def error_notifier
      options[:error_notifier]
    end

    def env_params
      ENV[env_connection_key]
    end

    def default
      options[:connection_params] || {host: '127.0.0.1'}
    end

    def ==(other)
      other.connection_params == connection_params &&
        other.env_connection_key == env_connection_key
    end
  end
end
