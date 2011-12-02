require 'pp'
require 'feedback_process_queue'
module Sim

  class SimulationScheduler < Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table
    attr_accessor :timeline

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      super(input, output)
      @process_table = SimulationSchedulerProcessTable.new
    end

    def run!(prelims, timeline)
      @timeline = timeline
      @stats = { :number_of_processes => prelims[0],
                 :thread_switch       => prelims[1],
                 :process_switch      => prelims[2],
                 :threads             => [],
                 false                => 0
               }
      # Handle beginning time.  Before any processes get there
      # Also context switch to the first process when it arrives
      preemption_timer = Timer.new()
      while @process_table.empty?
        @process_table << @timeline.new_threads_at(System::CLOCK.time)
        System::CLOCK.tick!
      end
      context_switch_timer = Timer.new(@stats[:process_switch])
      until context_switch_timer.buzzing?
        @process_table << @timeline.new_threads_at(System::CLOCK.time).each {|t| System::LOGGER << t.new_to_ready}
        context_switch unless @process_table.empty?
        System::CLOCK.tick!
      end
      context_switch_timer = Timer.new(false)

      # Main loop.  Until the process table is empty...
      until @process_table.done? && System::CLOCK.time > @timeline.last_arrival
        # Update the process table and add any new threads
        @process_table << @timeline.new_threads_at(System::CLOCK.time)
        @timeline.new_threads_at(System::CLOCK.time).each {|t| System::LOGGER << t.new_to_ready}

        # Take care of any unblocked threads
        @process_table.blocked_threads.each do |thread|
          if thread.blocked_timer.buzzing?
            @process_table.readify_thread!(thread)
            System::LOGGER << thread.blocked_to_ready
          end
        end

        context_switch_timer = Timer.new(false) if context_switch_timer.buzzing?
        if context_switch_timer.alarm
          context_switch
          System::CLOCK.tick!
          next
        end

        # Get the next ready thread and run it IF it exists!
        if @process_table.running_thread.nil? && @process_table.next_ready_thread
          @process_table.running_thread = @process_table.run_thread! @process_table.next_ready_thread
          System::LOGGER << @process_table.running_thread.ready_to_running
        end

        if @process_table.running_thread
          running_thread
        else
          cpu_idle
        end

        System::CLOCK.tick!

        if @process_table.running_thread && @process_table.running_thread.terminateable?
          previous_thread = @process_table.running_thread
          @stats[:threads] << @process_table.terminate_thread!(@process_table.running_thread).to_hash
          System::LOGGER << previous_thread.running_to_terminated
          completion_time = THREAD_COMPLETION_OVERHEAD
          completion_time = PROCESS_COMPLETION_OVERHEAD if @process_table.process_complete?(previous_thread.ppid)
          context_switch_timer = Timer.new( @stats[@process_table.context_switch_type(previous_thread)] + completion_time ) 
        end

        if @process_table.running_thread && @process_table.running_thread.burst_done_running? 
          previous_thread = @process_table.block_thread! @process_table.running_thread
          System::LOGGER << previous_thread.running_to_ready
          context_switch_timer = Timer.new(@stats[:thread_switch])
        end
      end
      finished
      @stats
    end

  end
end
