require File.join(File.dirname(__FILE__), 'thread')

module Sim
  class ThreadTimeline
    attr_accessor :threads

    def initialize(threads = [])
      @threads = threads
    end

    def [](time)
      @threads.select {|thread| thread.arrival == time }
    end

    def new_threads_at(time)
      self[time]
    end

    def << (thread)
      @threads << thread
    end
  end
end