require "big"

class Node
  property p : Node?
  property n : Node?
  property i : BigInt

  def initialize(@i)
    @n = nil
    @p = nil
  end

  def walk(&block : Node -> _)
    x = self.n
    block.call(self)
    until x.nil? || x == self
      block.call(x)
      x = x.n
    end
  end
end


class Day20
  @list : Array(Node)

  def initialize(file : String)
    @list = File.read_lines(file).map do |line|
      Node.new(line.to_big_i)
    end

    # connect the linked list
    @list.size.times do |i|
      @list[i].p = @list[i-1]
      @list[i].n = i == @list.size-1 ? @list[0] : @list[i+1]
    end
  end

  def shift_link(i : Int32)
    link = @list[i]

    # how many times to move (large numbers just make loops)
    n = link.i.abs % (@list.size - 1)
    x = link

    # disconnect the link
    if n != 0
      link.p.not_nil!.n = link.n
      link.n.not_nil!.p = link.p

      # walk to new location
      if link.i < 0
        n.times {x=x.p.not_nil!}
        link.p = x.p
        link.n = x
        x.p.not_nil!.n = link
        x.p = link
      else
        n.times {x=x.n.not_nil!}
        link.n = x.n
        link.p = x
        x.n.not_nil!.p = link
        x.n = link
      end
    end
  end

  def grove_coords
    link = @list.find {|link| link.i == 0}.not_nil!
    grove = 0

    (1..3000).each do |i|
      link = link.n.not_nil!

      # grove coordinate?
      grove += link.i if i == 1000 || i == 2000 || i == 3000
    end

    grove
  end

  def print_numbers
    @list[0].walk {|link| print "#{link.i} "}
    puts ""
  end

  def part1
    @list.size.times do |i|
      shift_link(i)
      #print_numbers
    end

    grove_coords
  end

  def part2
    @list.each {|link| link.i *= 811589153}

    10.times do
      @list.size.times {|i| shift_link(i)}
      #print_numbers
    end

    grove_coords
  end
end

day = Day20.new("data.txt")

#puts day.part1
puts day.part2
