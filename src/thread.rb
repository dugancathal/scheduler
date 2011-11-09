module Sim
  class Thread
    attr_accessor :arrival, :bursts, :burst_lengths
    def initialize(arrival, bursts)
      @arrival = arrival
      @bursts = bursts
      @burst_lengths = []
    end

    def add_burst(cpu_length, io_length = 0)
      @burst_lengths << {cpu: cpu_length, io: io_length}
    end
  end
end