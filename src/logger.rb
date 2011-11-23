module Sim
  class Logger
    attr_accessor :logs, :out

    def initialize(options = {:out => STDOUT})
      @logs = []
      @out = options.delete(:out) if options[:out]
    end

    def << (line)
      @logs << line
    end

    def output
      @out.puts @logs
    end

    def to_s
      @logs
    end
  end
end
