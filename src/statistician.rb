require 'terminal-table'
require 'logger'
require File.join(File.dirname(__FILE__), 'timer')

module Sim
  class Statistician
    attr_accessor :stats, :logs, :out, :timer
    def initialize(prelims = {out: STDOUT, threads: [] })
      @stats = prelims
      @out = @stats.delete(:out) if @stats[:out]
      if @stats[:verbose]
        @stats.delete(:verbose)
        @logs = Logger.new(out: @out)
      end
			@logs ||= []
      @timer = Timer.new
      @stats[:threads] ||= []
    end

    def print_stats(mode = @stats[:mode])
      case mode
      when :default  then default_stats
      when :detailed then detailed_stats
      when :verbose  then verbose_stats
      end
    end

    def tick!
      @timer.increment!
    end

    def default_stats
      @out.puts "Total time:      #{@timer.time}"
      rows = []
      @out.puts "CPU Utilization: #{@stats[:cpu_utilization]}"
      @stats[:threads].each do |thread|
        rows << [thread[:pid], thread[:id], thread[:turnaround]]
      end
      headings = %w(PID Thread\ ID Turnaround\ Time)
      @out.puts Terminal::Table.new(headings: headings) {|t| t.rows = rows}
    end

    def detailed_stats
      @out.puts "Total time:      #{@timer.time}"
      rows = []
      @out.puts "CPU Utilization: #{@stats[:cpu_utilization]}"
      @stats[:threads].each do |thread|
        rows << [thread[:pid], thread[:id], thread[:arrival], thread[:turnaround], thread[:service], thread[:io], thread[:finish]]
      end
      headings = %w(PID Thread\ ID Arrival Turnaround\ Time Service\ Time I/O\ Time Finish)
      @out.puts Terminal::Table.new(headings: headings) {|t| t.rows = rows}
    end

    def verbose_stats
      @logs.output
    end

    def << statistic
      @stats.merge! statistic if statistic.is_a?(Hash)
    end

    def [] stat
      @stats[stat]
    end
  end
end
