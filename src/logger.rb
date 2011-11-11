module Sim
  class Logger
    attr_accessor :logs, :out

    def intialize(options = {out: STDOUT})
      @logs = []
      @out = options.delete(:out) if options[:out]
    end

    def << (line)
      @logs << line
    end

    def output
      @out.puts @logs
    end
  end
end
