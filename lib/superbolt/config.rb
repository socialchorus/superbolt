module Superbolt
  class Config
    attr_reader :options

    def initialize(options={})
      @options = options
    end

    def connection_params
      env_params || default
    end

    def env_connection_key
      options[:connection_key] || 'RABBITMQ_URL'
    end

    def env_params
      ENV[env_connection_key]
    end

    def default
      options[:connection_params] || {host: '127.0.0.1'}
    end
  end
end
