class Day12
  def initialize(file : String)
    @map = [] of Array(Int32)
    @sx = 0
    @sy = 0
    @ex = 0
    @ey = 0

    File.each_line(file) do |line|
      row = [] of Int32

      line.chars.each do |c|
        case c
        when 'S'; row << 0; @sx = row.size - 1; @sy = @map.size
        when 'E'; row << 25; @ex = row.size - 1; @ey = @map.size
        else      row << c.ord - 'a'.ord
        end
      end
      @map << row
    end

    puts "#{{@sx, @sy}}"
    puts "#{{@ex, @ey}}"
  end

  def height(x : Int32, y : Int32) : Int32?
    @map[y][x] if 0 <= y < @map.size && 0 <= x < @map[y].size
  end

  def neighbors(node : Tuple(Int32, Int32, Int32)) : Array(Tuple(Int32, Int32, Int32))
    x, y, d = node

    # height of this node and tranversable neighbors
    h = height(x, y).not_nil!
    ns = [] of Tuple(Int32, Int32, Int32)

    # traversable neighbors
    ns << {x - 1, y, d + 1} if height(x - 1, y).try { |h2| h2 <= h + 1 }
    ns << {x + 1, y, d + 1} if height(x + 1, y).try { |h2| h2 <= h + 1 }
    ns << {x, y - 1, d + 1} if height(x, y - 1).try { |h2| h2 <= h + 1 }
    ns << {x, y + 1, d + 1} if height(x, y + 1).try { |h2| h2 <= h + 1 }

    ns
  end

  def pathfind_from(x : Int32, y : Int32) : Int32?
    node = {x, y, 0}
    nodes = neighbors(node)

    # never visit a node more than once
    visited = Set(Tuple(Int32, Int32)).new
    visited << {x, y}

    # loop until end reached or no more nodes to traverse
    while node[0] != @ex || node[1] != @ey
      return nil if nodes.empty?

      # always the shortest route to this node
      node = nodes.pop

      # get the possible neighbors from here not yet visited
      neighbors(node).each do |n|
        unless visited.includes?({n[0], n[1]})
          visited << {n[0], n[1]}
          nodes << n
        end
      end

      # follow the shortest path
      nodes.sort_by! { |n| -n[2] }
    end

    node[2]
  end

  def part1
    puts pathfind_from(@sx, @sy)
  end

  def part2
    shortest : Int32? = nil

    @map.each_with_index do |row, y|
      row.each_with_index do |height, x|
        if height == 0
          pathfind_from(x, y).try do |len|
            shortest = len if shortest.nil? || len < shortest
          end
        end
      end
    end

    puts shortest
  end
end

day = Day12.new("data.txt")

day.part1
day.part2
