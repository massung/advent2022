def conv_letter(c : Char)
  if c.ascii_uppercase?
    c.ord - 'A'.ord + 27
  else
    c.ord - 'a'.ord + 1
  end
end

class Sack
  @a : UInt64
  @b : UInt64

  def initialize(s : String)
    @a = 0
    @b = 0

    s.chars.each_with_index do |c, i|
      if i < s.size//2
        @a |= 1_u64 << conv_letter(c)
      else
        @b |= 1_u64 << conv_letter(c)
      end
    end
  end

  def common_letter
    (1...53).find do |i|
      ((1_u64 << i) & @a) > 0 && ((1_u64 << i) & @b > 0)
    end
  end

  def all_letters
    @a | @b
  end
end

def part_1
  total = 0

  File.each_line("data.txt") do |line|
    sack = Sack.new(line)
    sack.common_letter.try { |i| total += i }
  end

  total
end

def part_2
  total = 0

  # create groups of 3 sacks each
  File.read_lines("data.txt").each_slice(3) do |lines|
    letters = lines.reduce(UInt64::MAX) do |acc, s|
      acc & Sack.new(s).all_letters
    end

    # find the common letter
    common = (1...53).find do |i|
      ((1_u64 << i) & letters) > 0
    end

    # add to the total
    common.try { |c| total += c }
  end

  total
end

puts part_1.to_s
puts part_2.to_s
