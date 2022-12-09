alias Move = Tuple(Char, Int32)
alias Point = Tuple(Int32, Int32)

class Day9
  @moves : Array(Move)

  def initialize(file : String)
    @moves = File.read_lines(file).map do |line|
      {line[0], line[2..].to_i}
    end
  end

  def move_head(head : Point, dir : Char) : Point
    x = head[0]
    y = head[1]

    case dir
    when 'U'; y -= 1
    when 'D'; y += 1
    when 'L'; x -= 1
    when 'R'; x += 1
    else      raise "ACK!"
    end

    # updated position
    {x, y}
  end

  def move_tail(head : Point, tail : Array(Point))
    x = head[0]
    y = head[1]

    # shift the tail in reverse order
    (tail.size - 1).downto(0) do |i|
      tx = tail[i][0]
      ty = tail[i][1]

      # delta from head
      dx = x - tx
      dy = y - ty

      # move and update "head" if far away
      if dx.abs > 1 || dy.abs > 1
        tail[i] = {tx + dx.sign, ty + dy.sign}
      end

      # tail position is new "head" position
      x = tail[i][0]
      y = tail[i][1]
    end
  end

  def run(tail_size : Int)
    head = {0, 0}
    tail = Array.new(tail_size) { {0, 0} }

    # track visited tiles of tail
    visited = Set(Point).new

    # perform moves
    @moves.each do |move|
      move[1].times do
        head = move_head(head, move[0])

        # update the tail to follow
        move_tail(head, tail)

        # track visited locations
        visited << tail[0]
      end
    end

    # return number of tiles visited
    visited.size
  end
end

day9 = Day9.new("data.txt")

puts day9.run(1)
puts day9.run(9)
