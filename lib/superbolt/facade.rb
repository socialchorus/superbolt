module Superbolt
    
  def self.config=(options)
    @config = Config.new({
      env: env,
      app_name: app_name,
      file_matcher: file_matcher
    }.merge(options))
  end

  def self.config
    @config ||= Config.new
  end

  def self.queue(name)
    Superbolt::Queue.new(name, config)
  end

  class << self
    attr_writer :env, :file_matcher
    attr_accessor :app_name
  end

  def self.env
    @env || 'development'
  end

  def self.file_matcher
    @file_matcher || /_file$/
  end

  def self.message(args={})
    Superbolt::Messenger.new(args)
  end
end
