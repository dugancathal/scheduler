#
# Author:: TJ Taylor
# Copyright:: None
# 

# This class embodies the concept of a thread in the context
# of the scheduler for CSCI 442: Operating System Design Fall 2011

module Sim
  class Thread
    STATES = %w(new ready running blocked terminated).map! {|s| s.to_sym}
    TRANSITIONS = [
      :new_to_ready,
      :ready_to_running,
      :running_to_blocked,
      :blocked_to_ready,
      :running_to_ready,
      :running_to_terminated
    ]

    # [Attributes]
    # * arrival       - the arrival time of the thread
    # * bursts        - the number of cpu/io bursts
    # * state         - one of STATES
    # * transitions   - the transitions undergone by this thread
    # * burst_lengths - a list of all the bursts (io/cpu) to be undergone by this thread
    # * completion    - the time that the process completed
    attr_accessor :arrival, :bursts, :burst_lengths, :state, :transitions
    attr_accessor :completion, :ppid
    # Set intial values and initialize @burst_lengths array
    def initialize(arrival, bursts, ppid = 1)
      @arrival = arrival.to_i
      @bursts = bursts.to_i
      @ppid = ppid
      @burst_lengths = []
      @state = :ready
      @transition = :new_to_ready
    end
    
    # Essentially a accessor method for the @burst_lengths array
    def add_burst(cpu_length, io_length = 0)
      io_length ||= 0
      @burst_lengths << {cpu: cpu_length.to_i, io: io_length.to_i}
    end
  end
end