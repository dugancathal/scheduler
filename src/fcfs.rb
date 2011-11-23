module Sim

  class FCFSProcessTable < ProcessTable
    def next_ready_thread
      @ready_threads.first
    end
  end
  
  class FCFSScheduler < Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table
    attr_accessor :timeline

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      super(input, output)
      @process_table = FCFSProcessTable.new
    end

    def run!(prelims, timeline)
      @timeline = timeline
      @stats = { :number_of_processes => prelims[0],
                 :thread_switch       => prelims[1],
                 :process_switch      => prelims[2],
                 :threads             => []
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
          puts "Blocking Thread: #{thread.thread_id}"
          @process_table.readify_thread!(thread) if thread.blocked_timer.buzzing?
        end

        if @process_table.running_thread && @process_table.running_thread.terminateable?
          @process_table.terminate_thread! @process.running_thread
        end

        if @process_table.running_thread
          running_thread
        else
          output_idle
        end

        System::CLOCK.tick!

        if @process_table.running_thread && @process_table.running_thread.running_timer.buzzing?
          @process_table.block_thread! @process_table.running_thread
          context_switch :thread_switch
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
