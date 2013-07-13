module Superbolt
  def self.config=(options)
    @config = Config.new(options)
  end

  def self.config
    @config ||= Config.new
  end

  def self.queue(name)
    Superbolt::Queue.new(name, config)
  end

  class << self
    attr_writer :env
    attr_accessor :app_name
  end

  def self.env
    @env || 'development'
  end

  def self.message(args={})
    Superbolt::Messenger.new(args)
  end
end
