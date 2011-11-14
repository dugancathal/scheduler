module Sim
  class FCFSScheduler < Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table, :current_pid
    attr_accessor :current_thread, :timeline

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def run!(prelims, timeline)
      #prelims = @in.gets.chomp.split.map {|n| n.to_i }
      blocked_threads = []
      @timeline = timeline
      @stats = { number_of_processes: prelims[0],
                 thread_switch:       prelims[1],
                 process_switch:      prelims[2],
                 threads:             []
               }

      until @process_table.done? && System::CLOCK.time > @timeline.last_arrival
        @process_table << @timeline.new_threads_at(System::CLOCK.time)

        break if @process_table.ready_threads.size >= 5

        System::CLOCK.tick!
        if @current_thread && @current_thread.running_timer.buzzing?
          @process_table.block_thread! @current_thread
        end
      end
      finished
      @stats
    end

  end
end
