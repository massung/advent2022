class Day14
  @abyss : Int32
  @floor : Int32
  
  def initialize(file : String)
    @walls = Set(Tuple(Int32, Int32)).new
    @sand = Set(Tuple(Int32, Int32)).new
    @start = {500i32, 0i32}
    
    File.each_line(file) do |line|
      pts = line.split(" -> ").map(&.split(",").map &.to_i)
      
      # A -> B, B -> C, C -> D, ...
      pts.each_cons_pair do |a, b|
        x1, x2 = a[0] < b[0] ? {a[0], b[0]} : {b[0], a[0]}
        y1, y2 = a[1] < b[1] ? {a[1], b[1]} : {b[1], a[1]}
       
        # place rocks
        (x1..x2).each {|x| @walls << {x, y1}}
        (y1..y2).each {|y| @walls << {x1, y}}
      end
    end
    
    # greatest y value
    @abyss = @walls.map(&.[1]).max
    @floor = @abyss + 2
  end
  
  def [](x : Int32, y : Int32) : Bool
    y == @floor || @walls.includes?({x, y}) || @sand.includes?({x, y})
  end
  
  def drop_sand
    x, y = @start
    
    while y < @floor
      if !self[x, y+1]
        y += 1
      elsif !self[x-1, y+1]
        x -= 1
      elsif !self[x+1, y+1]
        x += 1
      else
        break
      end
    end
    
    # place the sand and return the position of it
    @sand << {x, y}
    {x, y}
  end
  
  def drop_until(&pred : (Tuple(Int32, Int32)) -> Bool) : Int32    
    (0..).index {|_| pred.call(drop_sand)}.not_nil!
  end
  
  def part1
    @sand.clear
    drop_until {|p| p[1] > @abyss}
  end
  
  def part2
    @sand.clear
    drop_until {|p| p == @start} + 1
  end
end

day = Day14.new("data.txt")

puts day.part1
puts day.part2