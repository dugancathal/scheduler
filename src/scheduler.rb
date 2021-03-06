require File.join(File.dirname(__FILE__), 'process_table')

module Sim
  class Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table, :current_pid
    attr_accessor :current_thread, :timeline

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      @in, @out = input, output
      @process_table = ProcessTable.new
    end

    def run!(prelims, timeline)
      output_idle while @in.gets.chomp != '-'
      finished
    end

    def cpu_idle
      @out.puts "I"
    end

    def running_thread
      @out.puts "R #{@process_table.running_thread.ppid} #{@process_table.running_thread.thread_id}"
    end

    def context_switch(type=:thread_switch)
      if thread = @process_table.running_thread #@process_table.next_ready_thread
        @out.puts "C #{thread.ppid} #{thread.thread_id}"
      else
        cpu_idle
      end
    end
    
    def finished
      @out.puts "-"
    end
  end
end
