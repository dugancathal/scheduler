require File.join(File.dirname(__FILE__), 'process')
require File.join(File.dirname(__FILE__), 'thread')

module Sim
  class Parser

    def self.parse!(input = STDIN)
      line = input.gets.chomp
      case line
      when ''  then return :empty
      when '.' then return :idle
      when '-' then return :eof
      when /^A \d+ \d+/
        return arrival line, input
      when /^C \d+ \d+/
        return cpu_bound line, input
      when /^I \d+ \d+/
        return io_bound line, input
      when /^E \d+ \d+/
        return process_end line, input
      end
    end

  private
      def self.arrival(line, input)
        /^A (?<pid>\d+) (?<threads>\d+)/ =~ line
        p = Process.new(pid.to_i, threads.to_i)
        p.num_threads.times { p << parse_thread!(pid.to_i, input); gets; }
        p
      end

      def self.parse_thread!(pid, input = STDIN)
        row, lines = [], []
        row = input.gets.chomp.split
        t = Thread.new(row[0].to_i, row[1].to_i, pid.to_i)
        t.bursts.times do
          row = input.gets.chomp.split
          t.add_burst *row
        end
        t
      end

      def self.cpu_bound(line, input)
        /^C (?<thread_id>\d+) (?<time>\d+)/ =~ line
        [:cpu_bound, thread_id.to_i, time.to_i]
      end

      def self.io_bound(line, input)
        /^I (?<thread_id>\d+) (?<time>\d+)/ =~ line
        [:io_bound, thread_id.to_i, time.to_i]        
      end

      def self.process_end(line, input)
        /^E (?<pid>\d+) (?<thread_id>\d+)/ =~ line
        [:end, pid.to_i, thread_id.to_i]
      end
  end
end
