class Val
  include Comparable(Val)

  # can be one of these types
  getter x : Int32 | Array(Val)

  def initialize(@x : Int32 | Array(Val))
  end

  def push(x : Val)
    @x.as(Array(Val)) << x
    self
  end

  def <=>(other : Val) : Int32
    case {@x.is_a?(Int32), other.x.is_a?(Int32)}
    when {true, true} ; @x.as(Int32) <=> other.x.as(Int32)
    when {true, false}; Val.new([Val.new(@x)]) <=> other
    when {false, true}; self <=> Val.new([Val.new(other.x)])
    else
      xs = @x.as(Array(Val))
      ys = other.x.as(Array(Val))

      case {xs.empty?, ys.empty?}
      when {true, false}; return -1
      when {false, true}; return 1
      when {true, true} ; return 0
      else
        cmp = xs[0] <=> ys[0]
        cmp != 0 ? cmp : Val.new(xs[1..]) <=> Val.new(ys[1..])
      end
    end
  end
end

class Day13
  @lists = [] of {Val, Val}

  def initialize(file : String)
    lines = File.read_lines(file)

    (0...lines.size).step(by: 3).each do |i|
      @lists << {parse_val(lines[i]), parse_val(lines[i + 1])}
    end
  end

  def parse_val(s : String) : Val
    val : Val = Val.new([] of Val)
    stack = [] of Val
    i = 0

    until i >= s.size
      case s[i..]
      when .match(/^\[/) ; i += 1; stack << val; val = Val.new([] of Val)
      when .match(/^\]/) ; i += 1; val = stack.pop.push(val)
      when .match(/^\d+/); i += $0.size; val.push(Val.new($0.to_i))
      else                 i += 1
      end
    end

    val
  end

  def part1
    puts @lists.map_with_index { |pair, i| (pair[0] <=> pair[1] < 0) ? i + 1 : 0 }.sum
  end

  def part2
    two = parse_val("[[2]]")
    six = parse_val("[[6]]")

    xs = [two, six] of Val

    @lists.each do |pair|
      xs << pair[0]
      xs << pair[1]
    end

    # sort them all
    xs.sort!

    # find the indices
    puts (xs.index!(two) + 1) * (xs.index!(six) + 1)
  end
end

day = Day13.new("data.txt")

day.part1
day.part2
