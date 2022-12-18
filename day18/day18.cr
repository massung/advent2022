alias Pt = {x: Int32, y: Int32, z: Int32}

class Day18
  @x : Range(Int32, Int32)
  @y : Range(Int32, Int32)
  @z : Range(Int32, Int32)

  def initialize(file : String)
    @pts = Set(Pt).new

    File.each_line(file) do |line|
      xyz = line.split(',').map &.to_i
      @pts << {x: xyz[0], y: xyz[1], z: xyz[2]}
    end

    # find extents
    minx = @pts.map(&.[:x]).min
    miny = @pts.map(&.[:y]).min
    minz = @pts.map(&.[:z]).min
    maxx = @pts.map(&.[:x]).max
    maxy = @pts.map(&.[:y]).max
    maxz = @pts.map(&.[:z]).max

    # convert extents to ranges
    @x = minx..maxx
    @y = miny..maxy
    @z = minz..maxz
  end

  def adjacent(pt : Pt) : Array(Pt)
    [{x: pt[:x] - 1, y: pt[:y], z: pt[:z]},
     {x: pt[:x] + 1, y: pt[:y], z: pt[:z]},
     {x: pt[:x], y: pt[:y] - 1, z: pt[:z]},
     {x: pt[:x], y: pt[:y] + 1, z: pt[:z]},
     {x: pt[:x], y: pt[:y], z: pt[:z] - 1},
     {x: pt[:x], y: pt[:y], z: pt[:z] + 1}]
  end

  def flood(pt : Pt) : Set(Pt)?
    q = [pt]
    closed = Set{pt}

    # bfs flood fill until trapped or escaped
    until q.empty?
      pt = q.pop

      # escaped?
      unless @x.includes?(pt[:x]) && @y.includes?(pt[:y]) && @z.includes?(pt[:z])
        return nil
      end

      # flood fill
      adjacent(pt).each do |n|
        unless @pts.includes?(n) || closed.includes?(n)
          q << n
          closed << n
        end
      end
    end

    # trapped closed set
    closed
  end

  def part1
    @pts.sum do |pt|
      adjacent(pt).sum {|n| @pts.includes?(n) ? 0 : 1}
    end
  end

  def part2
    closed = Set(Pt).new

    @pts.each do |pt|
      adjacent(pt).each do |n|
        unless @pts.includes?(n) || closed.includes?(n)
          flood(n).try {|c| closed += c}
        end
      end
    end

    # count sides touching pts
    part1 - closed.sum do |pt|
      adjacent(pt).sum {|n| @pts.includes?(n) ? 1 : 0}
    end
  end
end

day = Day18.new("data.txt")

puts day.part1
puts day.part2
