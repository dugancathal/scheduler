module Sim
  class Timer
    attr_accessor :time
    def initialize(n = 0)
      @time = n
    end
  
    def tick!
      @time+=1
    end
  end
end  
