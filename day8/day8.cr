class Day8
  @w : Int32
  @h : Int32

  def initialize(file : String)
    @grid = [] of Array(Int32)

    File.each_line(file) do |line|
      @grid << line.chars.map &.to_i
    end

    @w = @grid[0].size
    @h = @grid.size
  end

  def iter(&block : Int32, Int32, Int32 ->)
    @grid.each_with_index do |row, y|
      row.each_with_index do |h, x|
        block.call(x, y, h)
      end
    end
  end

  def walk(x : Int, y : Int, dx : Int, dy : Int, h : Int) : Int
    x += dx
    y += dy

    # off grid or blocked view
    return 0 if x < 0 || y < 0 || x == @w || y == @h
    return 1 if @grid[y][x] >= h

    # continue walking
    walk(x, y, dx, dy, h) + 1
  end

  def visible?(x : Int, y : Int, dx : Int, dy : Int, h : Int) : Bool
    x += dx
    y += dy

    # off grid or blocked view
    return true if x < 0 || y < 0 || x == @w || y == @h
    return false if @grid[y][x] >= h

    visible?(x, y, dx, dy, h)
  end

  def part1
    visible = 0

    # count all tiles that can be seen from the outside
    iter { |x, y, h| visible += 1 if visible?(x, y, -1, 0, h) ||
                                     visible?(x, y, 0, -1, h) ||
                                     visible?(x, y, 1, 0, h) ||
                                     visible?(x, y, 0, 1, h) }

    visible
  end

  def part2
    scenic_score = 0

    # find the best score
    iter do |x, y, h|
      score = walk(x, y, -1, 0, h) * walk(x, y, 1, 0, h) * walk(x, y, 0, -1, h) * walk(x, y, 0, 1, h)
      scenic_score = Math.max(score, scenic_score)
    end

    scenic_score
  end
end

day = Day8.new("data.txt")

puts day.part1
puts day.part2
