require 'process_table'
module Sim
  class SimulationSchedulerProcessTable < ProcessTable
    attr_accessor :current_queue_id
    def initialize(quanta = [2,4,8,16])
      @queues = quanta.map! { |quantum| FeedbackProcessQueue.new(quantum) }
      @blocked_threads = []
      @running_thread = nil
    end

    def done?
      @queues.reduce([]){|sum, q| sum+q.queue}.empty? && @blocked_threads.empty? && @running_thread.nil?
    end

    def next_ready_thread
      @queues.each_with_index do |q, i| 
        @cts_previous_queue_id = @current_queue_id = i;
        return @running_thread = q.pop if q.first
      end
      @cts_previous_queue_id = @current_queue_id = nil
    end

    def context_switch_type (previous_thread)
      if next_ready_thread.nil? || previous_thread.nil?
        return false
      end
      if previous_thread.ppid == next_ready_thread.ppid
        return :thread_switch
      else
        return :process_switch
      end
    end

    def << threads
      @queues[0].add threads
    end

    def preempt!
      @queues[@cts_previous_queue_id+1] << @running_thread
      next_ready_thread.run!
    end

    def current_queue
      @queues[@current_queue_id]
    end

    def current_quantum
      current_queue.quantum
    end

    def empty?
      @queues.each {|q| return false unless q.empty? }
      true
    end
    
    def block_thread!(thread, queue_id)
      @running_thread = nil if @running_thread == thread
      thread.block!
      @blocked_threads << {:thread => thread, :previous_queue => queue_id}
      thread
    end

    def readify_thread!(thread)
      thread.move_to_ready!
      thread = @blocked_threads.delete_if{|h| h[:thread] == thread }.first
      if thread[:previous_queue] < @queues.count
        @queues[thread[:previous_queue] + 1] << thread 
      else
        @queues[@queues.count] << thread
      end
      thread
    end

    def terminate_thread!(thread)
      thread.terminate!
      @running_thread = nil
      thread
    end

    def process_complete?(pid)
      (@queues.reduce{|sum,q| sum + q.queue}).select {|t| t.ppid == pid }.size == 0
    end
  end
end