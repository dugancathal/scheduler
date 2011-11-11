module Sim
  class Scheduler
    attr_accessor :stat, :out, :in
    attr_accessor :process_table, :current_pid
    attr_accessor :current_thread_id

    PROCESS_COMPLETION_OVERHEAD = 1
    THREAD_COMPLETION_OVERHEAD  = 1

    def initialize(input = STDIN, output = STDOUT)
      @in, @out = input, output
      @process_table = []
    end

    def run!(mode = :default, input = STDIN, output = STDOUT)
      @in, @out = input, output
      @process_table = []
      prelims = input.gets.chomp.split.map {|n| n.to_i }
      @stats = Statistician.new( number_of_processes: prelims[0],
                                 thread_switch:       prelims[1],
                                 process_switch:      prelims[2],
                                 out: @out,
                                 mode: mode )
      @stats[:number_of_processes].times { @process_table << Parser.parse!(@in); }
      @current_pid = @process_table.first.pid
      @current_thread_id = 0

      context_switch :process_and_thread
      until @process_table.empty?
        if @process_table.first.threads_complete? && @process_table.size == 1
					@current_pid = @process_table.first.pid
					@stats.logs << @process_table.pop
					@current_thread_id = 0
					break
				end	
        thread = @process_table.first.run_thread!(@current_thread_id, @stats)
				if thread
					@stats[:threads] << thread.to_hash
					context_switch unless @process_table.first.threads_complete?
					@current_thread_id += 1 # THIS IS FCFS
					thread = nil
				end
        #@stats.timer += 1
      end
      finished
      @stats.print_stats
    end

    def output_idle
      @out.puts "I"
    end

    def running_thread
      @out.puts "R #{@current_pid} #{@current_thread_id}"
    end

    def context_switch(type=:thread_switch)
			if type == :process_and_thread
			  type = (@stats[:process_switch]+@stats[:thread_switch])
			else
				type = @stats[type]
			end
			type.times do |n|
			  @out.puts "C #{@current_pid} #{@current_thread_id}"
				@stats.tick!
			end
    end
    
    def finished
      @out.puts "-"
    end
  end
end
