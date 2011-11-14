
module Sim
  class ProcessTable
    attr_accessor :ready_threads, :blocked_threads, :running_thread

    def initialize
      @ready_threads = []
      @blocked_threads = []
      @running_threads = nil
    end

    def done?
      @ready_threads.empty? && @blocked_threads.empty? && @running_thread.nil?
    end

    def << threads
      @ready_threads += threads
    end

    def block_thread!(thread)
      thread.block!
      @blocked_threads << @ready_threads.delete(thread)
    end

    def readify_thread!(thread)
      thread.move_to_ready!
      @ready_threads << @blocked_threads.delete(thread)
    end

    def run_thread(thread)
      thread.run!
      @running_thread = @ready_threads.delete(thread)
    end

  end
end