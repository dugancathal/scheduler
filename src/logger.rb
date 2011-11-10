module Sim
  class Statistician
    attr_accessor :logs, :calculations

    def intialize(which_logs = [])
      @logs = []
    end

    def << (line)
      @logs << line
    end

  end
end