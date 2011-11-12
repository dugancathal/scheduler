module Sim
  class Timer
    attr_accessor :time, :alarm
    def initialize(alarm = 1, n = 0)
      @time = n
      @alarm = alarm
    end
  
    def tick!
<<<<<<< HEAD
      @time+=1 if @alarm
    end

    def buzzing?
      @alarm && @time >= @alarm
=======
      @time+=1
>>>>>>> 8197acddf2ac86ab509cebd6dc436860c19bbc61
    end
  end
end  
