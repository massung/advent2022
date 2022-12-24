struct Blizzard
  getter x : Int32
  getter y : Int32
  getter dir : Symbol

  def initialize(@x, @y, @dir)
  end
end

class Route
  getter x : Int32
  getter y : Int32
  getter t : Int32

  def initialize(@x, @y, @t)
  end

  def ==(r : Route) : Bool
    r.x == @x && r.y == @y && r.t == @t
  end

  def hash(h)
    h = @x.hash(h)
    h = @y.hash(h)
    h = @t.hash(h)
    h
  end
end

class Day24
  @width : Int32
  @height : Int32
  @start : {Int32, Int32}
  @goal : {Int32, Int32}

  def initialize(file : String)
    lines = File.read_lines(file)

    # all blizzards
    @blizzards = Array(Blizzard).new

    # size of the map
    @width = lines[0].size - 2
    @height = lines.size - 2

    # start and goal
    @start = {lines[0][1..].index('.').not_nil!, -1}
    @goal = {lines[-1][1..].index('.').not_nil!, @height}

    # for every row/col, figure out which blizzards are there
    @blizzard_rows = Array(Array(Blizzard)).new(@height) {Array(Blizzard).new}
    @blizzard_cols = Array(Array(Blizzard)).new(@width) {Array(Blizzard).new}

    # record all the blizzards
    lines[1...-1].each_with_index do |line, y|
      line[1...-1].chars.each_with_index do |c, x|
        bliz = case c
               when '<'; Blizzard.new(x, y, :w)
               when '>'; Blizzard.new(x, y, :e)
               when '^'; Blizzard.new(x, y, :n)
               when 'v'; Blizzard.new(x, y, :s)
               end

        bliz.try do |b|
          @blizzard_rows[y] << b if b.dir == :w || b.dir == :e
          @blizzard_cols[x] << b if b.dir == :s || b.dir == :n
        end
      end
    end
  end

  def blizzard_pos(b : Blizzard, time : Int32) : {Int32, Int32}
    x, y = b.x, b.y

    # handle wrap around
    case b.dir
    when :n; y = (y - time) % @height
    when :s; y = (y + time) % @height
    when :w; x = (x - time) % @width
    when :e; x = (x + time) % @width
    end

    {x, y}
  end

  def draw_map(ex : Int32, ey : Int32, time : Int32)
    puts "#" * (@width+2)

    @height.times do |y|
      print '#'

      @width.times do |x|
        h = @blizzard_rows[y].select {|b| blizzard_pos(b, time)[0] == x}
        v = @blizzard_cols[x].select {|b| blizzard_pos(b, time)[1] == y}

        if (n = h.size + v.size) > 1
          print n.to_s
        else
          case {h.empty?, v.empty?}
          when {true, true}; print (x == ex && y == ey) ? 'E' : '.'
          when {false, true}; print (h[0].dir == :w) ? '<' : '>'
          when {true, false}; print (v[0].dir == :n) ? '^' : 'v'
          end
        end
      end

      # end of row
      puts "#"
    end

    puts "#" * (@width+2)
  end

  def manhattan(x : Int32, y : Int32) : Int32
    (@goal[0] - x).abs + (@goal[1] - y).abs
  end

  def heuristic(path : Route) : Int32
    manhattan(path.x, path.y) + path.t
  end

  def ok?(x : Int32, y : Int32, time : Int32) : Bool
    return true if x == @goal[0] && y == @goal[1]
    return false if x < 0 || y < 0 || x >= @width || y >= @height

    # any blizzard going to be there?
    @blizzard_rows[y].none? {|b| blizzard_pos(b, time)[0] == x} &&
    @blizzard_cols[x].none? {|b| blizzard_pos(b, time)[1] == y}
  end

  def open_moves(path : Route)
    x, y = path.x, path.y

    # increase times
    time = path.t + 1

    # stay put?
    if (x == @start[0] && y == @start[1]) || ok?(x, y, time)
      yield Route.new(x, y, time)
    end

    # move in a cardinal direction
    yield Route.new(x-1, y, time) if ok?(x-1, y, time)
    yield Route.new(x+1, y, time) if ok?(x+1, y, time)
    yield Route.new(x, y-1, time) if ok?(x, y-1, time)
    yield Route.new(x, y+1, time) if ok?(x, y+1, time)
  end

  def pathfind(start_time : Int32) : Route?
    open = Set{Route.new(@start[0], @start[1], start_time)}
    #closed = Set(Route).new
    n = 0

    # a-star pathfinding
    until open.empty?
      path = open.min_by {|path| self.heuristic(path)}
      open.delete(path)

      # reached goal?
      if path.x == @goal[0] && path.y == @goal[1]
        return path
      else
        open_moves(path) do |path|
          open << path unless open.includes?(path)
        end
      end
    end
  end

  def part1
    pathfind(0).not_nil!.t
  end

  def part2(start_time : Int32)
    # swap start and goal
    @goal, @start = @start, @goal
    back_time = pathfind(start_time).not_nil!.t

    @goal, @start = @start, @goal
    end_time = pathfind(back_time).not_nil!.t
  end
end

day = Day24.new("data.txt")

there = day.part1
and_back_again = day.part2(there)

puts there
puts and_back_again
