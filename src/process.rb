module Sim
  class Process
    attr_accessor :threads, :pid, :num_threads
    def initialize(pid, num_threads)
      @pid = pid
      @num_threads = num_threads
      @threads = []
    end

    def add_thread(thread)
      @threads << thread if thread.is_a?(Sim::Thread)
    end

    alias :<< :add_thread

    def [](thread_id)
      @threads[thread_id]
    end

    def run_thread!(thread_id)
      @threads[thread_id].state = :running
      @threads[thread_id].burst_lengths.first[:cpu].times do
        puts "R #{@pid} #{thread_id}\n"
      end
      @threads[thread_id].burst_lengths.pop
      @threads.delete_at(thread_id) if @threads[thread_id].burst_lengths.empty?
    end
  end
end
