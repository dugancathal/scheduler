module Sim
  class FeedbackProcessQueue
    attr_accessor :queue, :quantum

    def initialize(quantum = 1)
      @queue = []
      @quantum = quantum
    end

    def <<(thread)
      @queue << thread
    end

    def [](ppid, thread_id)
      @queue[@queue.index {|t| t.ppid == ppid && t.thread_id == thread_id}]
    end

    def first
      @queue.first
    end

    def pop
      @queue.delete_at 0
    end

    def push
      @queue.push
    end

    def add threads
      @queue += threads
    end

    def empty?
      @queue.empty?
    end
  end
end