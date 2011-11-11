module Sim
  class System
    
    attr_accessor :statistician, :out, :in
    attr_accessor :scheduler, :timer
    CLOCK = Clock

    def initialize(input = STDIN, output = STDOUT)
      @in, @out = input, output
    end

    def run!(options = {:mode => :default, type: Scheduler})
      prelims = @in.gets.chomp.split.map {|n| n.to_i }
      @statistician = Statistician.new( out: @out,
                                        mode: options[:mode] )
      @scheduler = options[:type].new(@in, @out)
      @statistician << @scheduler.run!(prelims)
      @statistician.print_stats
    end

  end
end