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
  
  def visible_ranges(y : Int32) : Array(Range(Int32, Int32))
    @sensors.map { |sensor| visible_range(sensor, y) }.sort_by! &.begin
  end
  
  def merged_ranges(y : Int32) : Array(Range(Int32, Int32))
    rs = visible_ranges(y)
    i = 0
    
    # merge overlapping ranges together
    (1...rs.size).each do |j|
      if rs[j].begin <= rs[i].end + 1
        rs[i] = rs[i].begin..Math.max(rs[i].end, rs[j].end)
      else
        rs[i += 1] = rs[j]
      end
    end
    
    rs.truncate(0, i + 1)
  end
  
  def part1(y : Int32) : Int32
    merged_ranges(y).sum do |r|
      r.size - @beacons.count { |b| b[:y] == y && r.includes?(b[:x]) }
    end
  end
  
  def part2(extent : Int32) : BigInt?
    (0..extent).each do |y|
      rs = merged_ranges(y)
      
      # if there's no free space, the first range will consume the entire area
      unless rs[0].includes?(0) && rs[0].includes?(extent)
        return BigInt.new(rs[0].end+1) * 4000000 + y 
      end
    end
  end
end

day = Day15.new("data.txt")

#puts day.part1(10)
#puts day.part2(20)

puts day.part1(2000000)
puts day.part2(4000000)
