SIGNALS = [20, 60, 100, 140, 180, 220]

class Day10
  def initialize(file : String)
    @cycle = 0
    @x = 1
    @signal = 0

    File.each_line(file) do |line|
      case line.match /addx (-?\d+)/
      when .nil?; step
      else        step; step; @x += $1.to_i
      end
    end

    puts @signal
  end

  def step
    @cycle += 1

    # signal tally
    @signal += @cycle * @x if SIGNALS.includes?(@cycle)

    # draw pixel
    pixel = (@cycle - 1) % 40

    # is pixel lit?
    if (@x - 1..@x + 1).includes?(pixel)
      print "#"
    else
      print "."
    end

    # last pixel?
    print "\n" if pixel == 39
  end
end

Day10.new("data.txt")
