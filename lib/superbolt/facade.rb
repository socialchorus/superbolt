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
end
