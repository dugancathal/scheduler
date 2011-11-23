#
# Author:: TJ Taylor
# Copyright:: None
# 

# This class embodies the concept of a thread in the context
# of the scheduler for CSCI 442: Operating System Design Fall 2011
require 'pp'
require File.join(File.dirname(__FILE__), 'timer')

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
    attr_accessor :arrival, :bursts, :burst_lengths, :state
    attr_accessor :completion, :ppid, :thread_id, :blocked_timer
    attr_accessor :running_timer, :current_burst_index
    # Set intial values and initialize @burst_lengths array
    def initialize(arrival, bursts, ppid = 1, thread_id = 0)
      @arrival = arrival.to_i
      @bursts = bursts.to_i
      @ppid = ppid
			@thread_id = thread_id
      @burst_lengths = []
      @state = :ready
      @running_timer = @blocked_timer = Timer.new(false)
      @current_burst_index = 0
    end
    
    # Essentially a accessor method for the @burst_lengths array
    def add_burst(cpu_length, io_length = nil)
      io_length = io_length.to_i unless io_length.nil?
      @burst_lengths << {:cpu => cpu_length.to_i, :io => io_length}
    end

    def to_hash
      {
        :pid         => @ppid,
        :id          => @thread_id,
        :turnaround  => @completion.to_i - @arrival.to_i,
				:arrival     => @arrival.to_i,
        :io          => @burst_lengths.reduce(0) {|sum, burst| sum + burst[:io].to_i },
				:service     => @burst_lengths.reduce(0) {|length, burst| length + burst[:cpu]},
				:finish      => @completion.to_i
      }
    end

    def block!
      if io_time = @burst_lengths.first[:io]
        #puts "Blocking with io_time: #{io_time}"
        @running_timer = Timer.new(false)
        @blocked_timer = Timer.new(io_time) 
        @state = :blocked
      else
        @blocked_timer = Timer.new(false)
        terminate!
      end
    end

    def move_to_ready!
      @state = :ready
      @blocked_timer = @running_timer = Timer.new(false)
      @current_burst_index += 1 if @current_burst_index < @burst_lengths.size#@burst_lengths.rotate!
    end

    def burst_done_running?
      @running_timer.buzzing?
    end

    def run!
      @running_timer = Timer.new(@burst_lengths[@current_burst_index][:cpu]) #.first[:cpu])
      @state = :running
    end

    def terminate!
      @completion = System::CLOCK.time
      @state = :terminated
    end

    def terminateable?
      @burst_lengths[@current_burst_index][:io].nil? && @running_timer.buzzing?
    end

    def blocked?
      @state == :blocked
    end

    def ready?
      @state == :ready
    end

    def running?
      @state == :running
    end

    def terminated?
      @state == :terminated
    end

    def blocked_to_ready
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from blocked to ready"
    end

    def null_to_new
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from null to new"
    end

    def new_to_ready
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from new to ready"
    end

    def ready_to_running
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from ready to running"
    end

    def running_to_ready
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from running to ready"
    end

    def running_to_terminated
      "At time #{System::CLOCK.time}: PID: #{@ppid} -> Thread: #{@thread_id} moved from running to terminated"
    end
  end
end
