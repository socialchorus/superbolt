module Superbolt
  class Transaction
    attr_accessor :config, :identifier

    def initialize(config=Superbolt.config)
      @config = config
      app_name = config.app_name
      env = config.env
      @identifier = app_name + '_' + env + '_' + Time.now.to_i.to_s
    end
  end
end
