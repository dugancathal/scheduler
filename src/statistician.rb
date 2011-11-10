module Sim
  class Statistician
    def self.print_stats(stats, mode = :default)
      case mode
      when :default  then self.default_stats(stats)
      when :detailed then self.detailed_stats(stats)
      when :verbose  then self.verbose_stats(stats)
      end
    end

    def self.default_stat(stats)
      puts "Total time:      #{stats[:time]}"
      puts "Turnaround Times:"
      stats[:turnaround_times].each do |time|
        puts "Process #{time[0]}: #{time[1]}"
      end
      puts "CPU Utilization: #{stats[:cpu_utilization]}"
    end

=begin
    In detailed information mode (i.e., -d flag is given), your simulator should output the total time
required to execute the threads in all the processes, the average turnaround time for all the pro-
cesses, the CPU utilization, and the arrival time, service time, I/O time, turnaround time, and
finish time for each thread.
=end
    def self.detailed_stats(stats)
      self.default_stats(stats)

  end
end