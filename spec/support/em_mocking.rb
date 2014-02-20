module EM
  def self.defer(&block)
    block.call
  end

  def self.next_tick(&block)
    block.call
  end
end