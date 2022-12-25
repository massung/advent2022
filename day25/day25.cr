require "big"

BASE=5.to_big_i

class Day25
  def initialize(file : String)
    @snafu = Array(BigInt).new

    File.each_line(file) do |line|
      @snafu << parse_snafu(line)
    end
  end

  def parse_snafu(s) : BigInt
    x = 0
    n = 0.to_big_i

    s.reverse.chars.each do |c|
      case c
      when '0'; n += 0
      when '1'; n += (BASE**x)
      when '2'; n += (BASE**x)*2
      when '-'; n -= (BASE**x)
      when '='; n -= (BASE**x)*2
      else raise "ACK!"
      end

      x += 1
    end

    n
  end

  def to_snafu(n : BigInt) : String
    s = n.to_s(base: 5)

    # fix the base-5 value to snafu
    ans = ""
    carry = 0

    s.reverse.chars.each do |c|
      case c.ord - '0'.ord + carry
      when 0; carry = 0; ans = "0#{ans}"
      when 1; carry = 0; ans = "1#{ans}"
      when 2; carry = 0; ans = "2#{ans}"
      when 3; carry = 1; ans = "=#{ans}"
      when 4; carry = 1; ans = "-#{ans}"
      when 5; carry = 1; ans = "0#{ans}"
      end
    end

    # maybe apply final carry
    (carry > 0 ? carry.to_s : "") + ans
  end

  def part1
    to_snafu(@snafu.sum)
  end

  def part2
    "Merry Christmas!!"
  end
end

day = Day25.new("data.txt")

puts day.part1
puts day.part2
