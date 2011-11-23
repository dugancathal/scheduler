require File.join(File.dirname(__FILE__), 'process')
require File.join(File.dirname(__FILE__), 'thread')
require File.join(File.dirname(__FILE__), 'thread_timeline')

module Sim
  class Parser

    def self.parse_input!(input = STDIN)
      prelims = input.gets.chomp.split.map {|n| n.to_i }
      input.gets
      threads = []
      prelims.first.times do |n| 
        proc_details = input.gets.chomp
        threads << self.arrival(proc_details, input)
      end
      timeline = ThreadTimeline.new(threads.flatten)
      [prelims, timeline]
    end

    #def self.parse!(input = STDIN)
    #  line = input.gets.chomp
    #  case line
    #  when ''  then return :empty
    #  when '.' then return :idle
    #  when '-' then return :eof
    #  when /^A\s+\d+\s+\d+/
    #    return arrival line, input
    #  when /^C\s+\d+\s+\d+/
    #    return cpu_bound line, input
    #  when /^I\s+\d+\s+\d+/
    #    return io_bound line, input
    #  when /^E\s+\d+\s+\d+/
    #    return process_end line, input
    #  end
    #end

  private
      def self.arrival(line, input)
        #/^(?<pid>\d+)\s+(?<threads>\d+)/ =~ line
        pid, threads = line.split[0..1]
        p = Process.new(pid.to_i, threads.to_i)
        p.num_threads.times { |n| p << parse_thread!(pid.to_i, n, input); input.gets; }
        p.threads
      end

      def self.parse_thread!(pid, id, input = STDIN)
        row, lines = [], []
        row = input.gets.chomp.split
        t = Thread.new(row[0].to_i, row[1].to_i, pid.to_i, id)
        t.bursts.times do
          row = input.gets.chomp.split
          t.add_burst *row
        end
        t
      end

      def self.cpu_bound(line, input)
        thread_id, time = line.split[1..2]
        [:cpu_bound, thread_id, time]
      end

      #def self.cpu_bound(line, input)
      #  /^C\s+(?<thread_id>\d+)\s+(?<time>\d+)/ =~ line
      #  [:cpu_bound, thread_id.to_i, time.to_i]
      #end

      #def self.io_bound(line, input)
      #  /^I\s+(?<thread_id>\d+)\s+(?<time>\d+)/ =~ line
      #  [:io_bound, thread_id.to_i, time.to_i]        
      #end

      #def self.process_end(line, input)
      #  /^E\s+(?<pid>\d+)\s+(?<thread_id>\d+)/ =~ line
      #  [:end, pid.to_i, thread_id.to_i]
      #end
  end
end
