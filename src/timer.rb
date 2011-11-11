module Sim
  class Timer
    attr_accessor :time, :alarm
    def initialize(alarm = 1, n = 0)
      @time = n
      @alarm = alarm
    end
  
    def tick!
      @time+=1 if @alarm
    end

    def buzzing?
      @alarm && @time >= @alarm
    end
  end
end  
