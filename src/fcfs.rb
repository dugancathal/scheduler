module Sim
  class FCFSScheduler < Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table, :current_pid
    attr_accessor :current_thread

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def run!(prelims)
      #prelims = @in.gets.chomp.split.map {|n| n.to_i }
      blocked_threads = []
      @stats = { number_of_processes: prelims[0],
                 thread_switch:       prelims[1],
                 process_switch:      prelims[2],
                 threads:             []
               }
      @stats[:number_of_processes].times { @process_table << Parser.parse!(@in); }
      @current_thread = @process_table.first.first_ready_thread
      @current_pid = @current_thread.ppid

      context_switch :process_and_thread
      until @process_table.empty?
        @current_thread ||= @process_table.first.first_ready_thread
        @current_pid = @current_thread.ppid if @current_thread
        if @current_thread && @current_thread.terminateable?
          @current_thread.terminate!
          @stats[:threads] << @current_thread.to_hash
          @current_thread = @process_table.first.first_ready_thread
          @current_pid = @current_thread.ppid if @current_thread
          context_switch :thread unless @process_table.first.threads_complete?
        end

        blocked_threads.each_with_index do |t,i|
          if t.blocked_timer.buzzing?
            t.move_to_ready!
            blocked_threads.delete_at i
          end
        end

        if @process_table.first.threads_complete? && @process_table.size == 1
					@current_pid = @process_table.first.pid
					@process_table.pop
					@current_thread = nil
					break
				end	

        @process_table.first.run_thread!(@current_thread) if @current_thread && @current_thread.ready?
        
        print "#{System::CLOCK.time} "
        if @current_thread
          running_thread
        else
          cpu_idle
        end

        #if @current_thread && @current_thread.terminateable?
        #  @current_thread.terminate!
        # @stats[:threads] << @current_thread.to_hash
        #  @process_table.pop # THIS IS FCFS, removes first thread and moves to next
        # context_switch :thread unless @process_table.first.threads_complete?
        # @current_thread = nil
        #end
        System::CLOCK.tick!
        if @current_thread && @current_thread.running_timer.buzzing?
          @current_thread.block!
          blocked_threads << @current_thread
        end
      end
      finished
      @stats
    end

  end
end
