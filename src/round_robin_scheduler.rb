module Sim

  class RoundRobinProcessTable < ProcessTable
    def next_ready_thread
      @ready_threads.first
    end

    def context_switch_type(previous_thread)
      if previous_thread.nil? || next_ready_thread.nil?
        :process_and_thread
      elsif previous_thread.ppid == next_ready_thread.ppid
        :thread_switch
      else
        :process_and_thread
      end
    end
  end
  
  class RoundRobinScheduler < Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table
    attr_accessor :timeline

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      super(input, output)
      @process_table = RoundRobinProcessTable.new
    end

    def run!(prelims, timeline)
      @timeline = timeline
      @stats = { number_of_processes: prelims[0],
                 thread_switch:       prelims[1],
                 process_switch:      prelims[2],
                 threads:             []
               }

      @process_table << @timeline.new_threads_at(0)
      #@process_table.run_thread! @process_table.next_ready_thread
      context_switch :process_and_thread
      until @process_table.done? && System::CLOCK.time > @timeline.last_arrival

        # Update the process table and add any new threads at this time
        @process_table << @timeline.new_threads_at(System::CLOCK.time)

        # Get the next ready thread and RUN IT if it exists!
        if @process_table.running_thread.nil? && @process_table.next_ready_thread
          @process_table.running_thread = @process_table.run_thread! @process_table.next_ready_thread
        end

        # Take care of any unblocked threads
        @process_table.blocked_threads.each do |thread|
          #puts "Blocking Thread: #{thread.thread_id}"
          @process_table.readify_thread!(thread) if thread.blocked_timer.buzzing?
        end

        if @process_table.running_thread.thread_id && @process_table.running_thread.burst_lengths.first[:io].nil?
          time = @process_table.running_thread.running_timer.alarm - @process_table.running_thread.running_timer.time
          #puts "THIS SHOULD TERMINATE IN #{time} seconds"
        end

        if @process_table.running_thread
          running_thread
        else
          output_idle
        end

        System::CLOCK.tick!

        #break if System::CLOCK.time >= 100

        if @process_table.running_thread && @process_table.running_thread.terminateable?
          previous_thread = @process_table.running_thread
          @stats[:threads] << @process_table.terminate_thread!(@process_table.running_thread).to_hash
          context_switch @process_table.context_switch_type(previous_thread)
          @process_table.run_thread! @process_table.next_ready_thread
        end

        if @process_table.running_thread && @process_table.running_thread.done_running?
          previous_thread = @process_table.block_thread! @process_table.running_thread
          context_switch @process_table.context_switch_type(previous_thread)
          @process_table.run_thread! @process_table.next_ready_thread
        end
      end
      #require 'pp'
      #pp @process_table
      finished
      @stats
    end

  end
end
