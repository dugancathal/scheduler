module Sim
  class Clock
    @@time = 0

    def self.tick!
      ObjectSpace.each_object(Timer) {|timer| timer.tick!}
      @@time += 1
    end

    def self.time
      @@time
    end
  end
end