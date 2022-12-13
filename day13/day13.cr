class Val
  include Comparable(Val)

  # can be one of these types
  getter x : Int32 | Array(Val)

  def initialize(@x : Int32 | Array(Val))
  end

  def is_int? : Bool
    @x.is_a?(Int32)
  end

  def <=>(other : Val) : Int32
    case {is_int?, other.is_int?}
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
        case xs[0] <=> ys[0]
        when -1; return -1
        when  1; return 1
        else     Val.new(xs[1..]) <=> Val.new(ys[1..])
        end
      end
    end
  end
end

class Day13
  @lists = [] of {Val, Val}

  def initialize(file : String)
    lines = File.read_lines(file)

    (0...lines.size).step(by: 3).each do |i|
      a, _ = parse_list(lines[i])
      b, _ = parse_list(lines[i + 1])

      @lists << {a, b}
    end
  end

  def parse_list(line : String, i : Int32 = 1) : Tuple(Val, Int32)
    xs = [] of Val

    until line[i] == ']'
      case line[i..]
      when .matches?(/^\[/)
        ys, i = parse_list(line, i + 1)
        xs << ys
      when .match(/^\d+/)
        xs << Val.new($0.to_i)
        i += $0.size
      else
        i += 1
      end
    end

    {Val.new(xs), i + 1}
  end

  def part1
    puts @lists.map_with_index { |pair, i| (pair[0] <=> pair[1] < 0) ? i + 1 : 0 }.sum
  end

  def part2
    two, _ = parse_list("[[2]]")
    six, _ = parse_list("[[6]]")

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
