module Sim
  class System
    
    attr_accessor :statistician, :out, :in
    attr_accessor :scheduler, :timer
    CLOCK = Clock

    def initialize(input = STDIN, output = STDOUT)
      @in, @out = input, output
    end

    def run!(options = {:mode => [:default], type: Scheduler})
      @statistician = Statistician.new( out: @out,
                                        mode: options[:mode] )
      prelims, timeline = Parser.parse_input!(@in)
      @scheduler = options[:type].new(@in, @out)
      @statistician << @scheduler.run!(prelims, timeline)
      @statistician.print_stats
    end

  end
end