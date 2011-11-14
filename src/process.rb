require File.join(File.dirname(__FILE__), 'thread')
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

    def run_thread!(thread)
      thread.run!
#      thread.burst_lengths.first[:cpu].times do |n|
#        puts "R #{@pid} #{thread_id}\n"
#        System::CLOCK.tick!
#      end
#      if thread.burst_lengths.first[:io].nil?
#        thread.completion = System::CLOCK.time
#        thread.burst_lengths.rotate!
#        return thread
#      end
#      thread.burst_lengths.rotate!
#      thread.block!
    end

    def first_ready_thread
      @threads.select{|t| t.ready?}.first
    end

		def threads_complete?
		  @threads.each do |thread|
			  return false unless thread.terminated?
			end
			true
    end
  end
end
