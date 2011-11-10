module Sim
  class Scheduler
    attr_accessor :stats, :out, :in
    attr_accessor :process_table, :current_pid
    attr_accessor :current_thread_id

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      @in, @out = input, output
      @process_table = []
      @time = 0
    end

    def run!(input = STDIN, output = STDOUT)
      @in, @out = input, output
      @process_table = []
      prelims = input.gets.chomp.split.map {|n| n.to_i }
      @stats = { number_of_processes:     prelims[0],
                 thread_switch_overhead:  prelims[1],
                 process_switch_overhead: prelims[2],
                 time:                    0 }
      @stats[:number_of_processes].times { @process_table << Parser.parse!(@in); }
      @current_pid = @process_table.first.pid
      @current_thread_id = 0

      (@stats[:process_switch_overhead]+@stats[:thread_switch_overhead]).times { context_switch }
      until @process_table.empty?
        @process_table.pop and break if @process_table.first.threads.empty?
        @process_table.first.run_thread!(@current_thread_id)
        @stats[:time] += 1
      end
      finished
      Statistician.print_stats(@stats)
    end

    def output_idle
      @out.puts "I"
    end

    def running_thread
      @out.puts "R #{@current_pid} #{@current_thread_id}"
    end

    def context_switch
      @out.puts "C #{@current_pid} #{@current_thread_id}"
    end
    
    def finished
      @out.puts "-"
    end
  end
end
