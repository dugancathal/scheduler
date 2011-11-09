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
  end
end
