module Sim
  class Timer
    attr_accessor :time, :alarm, :snoozing

    alias :snoozing? :snoozing

    def initialize(alarm = 1, n = 0)
      @time = n
      @alarm = alarm
    end
  
    def tick!
      @time+=1 if @alarm and not @snoozing
    end

    def buzzing?
      @alarm && @time >= @alarm
    end

    def snooze!
      @snoozing = true
    end

    def reset!
      @time = 0
      @snoozing = false
      self
    end
  end
end  
