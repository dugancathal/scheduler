require 'terminal-table'
require 'logger'

module Sim
  class Statistician
    attr_accessor :stats, :timer, :logs, :out
    def initialize(prelims = {out: STDOUT})
      @stats = prelims
      @out = @stats.delete(:out) if @stats[:out]
      if @stats[:verbose]
        @stats.delete(:verbose)
        @logs = Logger.new(out: @out)
      end
      @timer = 0
    end

    def print_stats(mode = :default)
      case mode
      when :default  then self.default_stats(@stats)
      when :detailed then self.detailed_stats(@stats)
      when :verbose  then self.verbose_stats(@stats)
      end
    end

    def default_stat
      @out.puts "Total time:      #{@timer}"
      rows = []
      @out.puts "CPU Utilization: #{@stats[:cpu_utilization]}"
      @stats[:threads].each do |thread|
        rows << [thread[:pid], thread[:id], thread[:turnaround]]
      enda
      headings = %w(PID Thread\ ID Turnaround\ Time)
      @out.puts Terminal::Table.new(headings: headings) {|t| t.rows = rows}
    end

    def detailed_stats
      @out.puts "Total time:      #{@timer}"
      rows = []
      @out.puts "CPU Utilization: #{@stats[:cpu_utilization]}"
      @stats[:threads].each do |thread, data|
        rows << [data[:pid], data[:id], data[:arrival], data[:turnaround], data[:service], data[:io], data[:finish]]
      end
      headings = %w(PID Thread\ ID Arrival Turnaround\ Time Service\ Time I/O\ Time Finish)
      @out.puts Terminal::Table.new(headings: headings) {|t| t.rows = rows}
    end

    def verbose_stats
      @logs.output
    end
  end
end
