require 'process_table'
module Sim
  class SimulationSchedulerProcessTable < ProcessTable
    attr_accessor :current_queue_id, :queues
    def initialize(quanta = [6,8,10,16])
      @cts_previous_queue_id = -1
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
      @cts_previous_queue_id = @current_queue_id = -1
      nil
    end

    def context_switch_type (previous_thread)
      if previous_thread.nil? || @running_thread.nil? || (@running_thread == previous_thread)
        return false
      end
      if previous_thread.ppid == @running_thread.ppid
        return :thread_switch
      else
        return :process_switch
      end
    end

    def << threads
      @queues[0].add threads
    end

    def preempt!
      @running_thread.running_timer.snooze!
      if @cts_previous_queue_id < @queues.size - 1
        @queues[@cts_previous_queue_id+1] << @running_thread
      else
        @queues[@cts_previous_queue_id] << @running_thread
      end
      @running_thread = next_ready_thread
    end

    def let_current_thread_run
      if @running_thread && @running_thread.running_timer.snoozing?
        @running_thread.run!
      end
    end

    def run_thread!(thread)
      thread.run!
    end

    def current_queue
      @queues[@current_queue_id]
    end

    def current_quantum
      current_queue.quantum
    end

    def queues_empty?
      @queues.each {|q| return false unless q.empty? }
      true
    end
    
    def block_thread!(thread)
      @running_thread = nil if @running_thread == thread
      thread.block!
      @blocked_threads << {:thread => thread, :previous_queue => @cts_previous_queue_id}
      thread
    end

    def readify_thread!(thread)
      thread[:thread].move_to_ready!
      @blocked_threads.delete_if{|h| (h[:thread].ppid == thread[:thread].ppid) && (h[:thread].thread_id == thread[:thread].thread_id) }
      if thread[:previous_queue] < @queues.count - 1
        @queues[thread[:previous_queue] + 1] << thread[:thread]
      else
        @queues[@queues.count - 1] << thread[:thread]
      end
      thread
    end

    def terminate_thread!(thread)
      thread.terminate!
      @running_thread = nil
      thread
    end

    def process_complete?(pid)
      (@queues.reduce([]){|sum,q| sum + q.queue}).select {|t| t.ppid == pid }.size == 0
    end
  end
end