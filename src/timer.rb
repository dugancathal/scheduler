module Sim
  class Timer
    attr_accessor :time
    def initialize(n = 0)
      @time = n
    end
  
    def increment!
      @time+=1
    end
  end
end  
