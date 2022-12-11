class Monkey
  @items : Array(Int64)
  @op : Int64 -> Int64
  @test : Int32
  @on_true : Int32
  @on_false : Int32
  @count : Int64

  def initialize(lines : Array(String))
    @items = lines[0].scan(/\d+/).map &.[0].to_i64
    @op = parse_op(lines[1])
    @test = lines[2].match(/\d+/).not_nil!.[0].to_i
    @on_true = lines[3].match(/\d+/).not_nil!.[0].to_i
    @on_false = lines[4].match(/\d+/).not_nil!.[0].to_i
    @count = 0
  end

  def parse_op(s : String) : Int64 -> Int64
    pos = s.index("new = old").not_nil!
    ops = s[pos + 10..].split

    case {ops[0].strip, ops[1].strip}
    when {"+", "old"}; ->(x : Int64) { x + x }
    when {"*", "old"}; ->(x : Int64) { x * x }
    when {"+", _}    ; ->(x : Int64) { x + ops[1].strip.to_i }
    when {"*", _}    ; ->(x : Int64) { x * ops[1].strip.to_i }
    else               raise Exception.new("ACK!")
    end
  end

  def recv(item : Int64)
    @items << item
  end

  def inspect_all(monkeys : Array(Monkey), relief : Int32?)
    @items.each { |item| inspect(item, monkeys, relief) }
    @count += @items.size
    @items.clear
  end

  def inspect(item : Int64, monkeys : Array(Monkey), relief : Int32?)
    worry = @op.call(item)

    if relief.nil?
      worry //= 3
    else
      worry %= relief if worry >= relief
    end

    # throw to the next monkey
    if worry % @test == 0
      monkeys[@on_true].recv(worry)
    else
      monkeys[@on_false].recv(worry)
    end
  end

  def test
    @test
  end

  def items_inspected
    @count
  end
end

class Day11
  def initialize(file : String)
    @monkeys = [] of Monkey

    lines = File.read_lines(file)

    # create all the monkeys
    (1...lines.size).step(7).each do |i|
      @monkeys << Monkey.new(lines[i...i + 5])
    end
  end

  def lcm
    (@monkeys.map &.test).product
  end

  def inspect_round(relief : Int32?)
    @monkeys.each { |m| m.inspect_all(@monkeys, relief) }
  end

  def most_inspected
    (@monkeys.sort_by &.items_inspected)[-2..]
  end
end

day = Day11.new("data.txt")

# part 1
# 20.times { day.inspect_round(nil) }

# part 2
10000.times { day.inspect_round(day.lcm) }

# show answer
puts((day.most_inspected.map &.items_inspected).product)
