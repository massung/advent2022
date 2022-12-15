require "big"

alias Pt = {x: Int32, y: Int32}
alias Sensor = {pt: Pt, rng: Int32}

class Day15
  def initialize(file : String)
    @sensors = Array(Sensor).new
    @beacons = Set(Pt).new
    
    File.each_line(file) do |line|
      xys = line.scan(/\d+/).map &.[0].to_i

      a = {x: xys[0], y: xys[1]}
      b = {x: xys[2], y: xys[3]}

      @sensors << {pt: a, rng: dist(a, b)}
      @beacons << b
    end
  end
  
  def dist(a : Pt, b : Pt) : Int32
    (a[:x] - b[:x]).abs + (a[:y] - b[:y]).abs
  end
  
  def visible_range(s : Sensor, y : Int32) : Range(Int32, Int32)
    dy = (s[:pt][:y] - y).abs
    
    x1 = s[:pt][:x] - s[:rng] + dy
    x2 = s[:pt][:x] + s[:rng] - dy
    
    (x1..x2)
  end
  
  def ranges_overlap?(r : Range(Int32, Int32), e : Range(Int32, Int32)) : Bool
    e.includes?(r.begin) || e.includes?(r.end) || r.includes?(e.begin) || r.includes?(e.end)
  end
  
  def merged_ranges(y : Int32) : Array(Range(Int32, Int32))
    rs = Array(Range(Int32, Int32)).new(@sensors.size)
    
    @sensors.each do |sensor|
      r = visible_range(sensor, y)
      
      # does this overlap an existing range?
      if i = rs.index { |e| ranges_overlap?(r, e) }
        rs[i] = Math.min(r.begin, rs[i].begin)..Math.max(r.end, rs[i].end)
      else
        rs << r
      end
    end
    
    rs.sort_by! &.begin
  end
  
  def part1(y : Int32) : Int32
    merged_ranges(y).sum do |r|
      r.size - @beacons.count { |b| b[:y] == y && r.includes?(b[:x]) }
    end
  end
  
  def part2(extent : Int32) : BigInt?
    (0..extent).each do |y|
      rs = merged_ranges(y).each
      x = 0

      while x <= extent
        case r = rs.next
        in Iterator::Stop; return BigInt.new(x) * 4000000 + y 
        in Range(Int32, Int32); x = r.end + 1 if r.includes?(x)
        end
      end
    end
  end
end

day = Day15.new("data.txt")

#puts day.part1(10)
#puts day.part2(20)

puts day.part1(2000000)
puts day.part2(4000000)
