module Superbolt
  def self.config=(options)
    @config = Config.new(options)
  end

  def self.config
    @config ||= Config.new
  end
end
