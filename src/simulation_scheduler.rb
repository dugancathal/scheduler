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
      preemption_timer = Timer.new(false)
      while @process_table.queues_empty?
        cpu_idle
        @process_table << @timeline.new_threads_at(System::CLOCK.time).each {|t| System::LOGGER << t.new_to_ready}
        System::CLOCK.tick!
      end
      context_switch_timer = Timer.new(@stats[:process_switch])
      @process_table.next_ready_thread
      until context_switch_timer.buzzing?
        @process_table << @timeline.new_threads_at(System::CLOCK.time).each {|t| System::LOGGER << t.new_to_ready}
        context_switch #unless @process_table.empty?
        System::CLOCK.tick!
      end
      context_switch_timer = Timer.new(false)
      preemption_timer.alarm = @process_table.current_quantum
      #@process_table.running_thread.running_timer.alarm = @process_table.running_thread.burst_lengths.first[:cpu]
      # Main loop.  Until the process table is empty...
      until @process_table.done? && System::CLOCK.time > @timeline.last_arrival
        # Update the process table and add any new threads
        @process_table << @timeline.new_threads_at(System::CLOCK.time).each {|t| System::LOGGER << t.new_to_ready}

        @process_table.blocked_threads.each do |thread|
          if thread[:thread].blocked_timer.buzzing?
            @process_table.readify_thread! thread
            System::LOGGER << thread[:thread].blocked_to_ready
          end
        end

        context_switch_timer = Timer.new(false) if context_switch_timer.buzzing?
        if context_switch_timer.alarm
          context_switch
          System::CLOCK.tick!
          next
        end

        @process_table.let_current_thread_run

        if @process_table.running_thread && @process_table.running_thread.cpu_burst_done_running?
          previous_thread = @process_table.running_thread
          unless @process_table.running_thread.terminateable?
            @process_table.block_thread! @process_table.running_thread
          else
            previous_thread = @process_table.running_thread
            @stats[:threads] << @process_table.terminate_thread!(@process_table.running_thread).to_hash
            System::LOGGER << previous_thread.running_to_terminated
            completion_time = THREAD_COMPLETION_OVERHEAD
            completion_time = PROCESS_COMPLETION_OVERHEAD if @process_table.process_complete?(previous_thread.ppid)
            context_switch_timer = Timer.new( @stats[@process_table.context_switch_type(previous_thread)] + completion_time )
          end
          
          @process_table.next_ready_thread
          preemption_timer.reset!.alarm = @process_table.current_quantum
          preemption_timer.snooze!
          if @process_table.running_thread.nil?
            context_switch_timer = Timer.new(false)
            next
          end
          context_switch_timer = Timer.new(@stats[@process_table.context_switch_type(previous_thread)])
          System::LOGGER << @process_table.running_thread.ready_to_running
          next
        end

        preemption_timer.snoozing = false if @process_table.running_thread
        if preemption_timer.buzzing?
          System::LOGGER << @process_table.running_thread.running_to_ready
          previous_thread = @process_table.running_thread
          @process_table.preempt!
          System::LOGGER << @process_table.running_thread.ready_to_running
          context_switch_timer = Timer.new(@stats[@process_table.context_switch_type(previous_thread)])
          preemption_timer.reset!.alarm = @process_table.current_quantum
          preemption_timer.snooze!
          next
        end

        if @process_table.running_thread && @process_table.running_thread.terminateable?
          previous_thread = @process_table.running_thread
          @stats[:threads] << @process_table.terminate_thread!(@process_table.running_thread).to_hash
          System::LOGGER << previous_thread.running_to_terminated
          completion_time = THREAD_COMPLETION_OVERHEAD
          completion_time = PROCESS_COMPLETION_OVERHEAD if @process_table.process_complete?(previous_thread.ppid)
          context_switch_timer = Timer.new( @stats[@process_table.context_switch_type(previous_thread)] + completion_time ) 
        end

        if @process_table.running_thread
          running_thread
        else
          cpu_idle
        end

        break if @process_table.done? && System::CLOCK.time > @timeline.last_arrival
        @process_table.next_ready_thread if @process_table.running_thread.nil?
        System::CLOCK.tick!
      end
      finished
      @stats
    end

  end
end
