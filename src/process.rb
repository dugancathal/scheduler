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

    def run_thread!(thread_id, timer)
      thread = @threads[thread_id]
      thread.state = :running
      thread.burst_lengths.first[:cpu].times do |n|
        puts "R #{@pid} #{thread_id}\n"
        timer.tick!
      end
      if thread.burst_lengths.first[:io].nil?
        thread.completion = timer.tick! - 1
        return thread
      end
      thread.burst_lengths.rotate!
      thread.state = :ready
			nil
    end

		def threads_complete?
		  @threads.each do |thread|
			  return false unless thread.completion
			end
			true
    end
  end
end
