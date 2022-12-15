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
    @sensors.map { |s| visible_range(s, y) }.sort_by! { |r| -r.begin }
  end
  
  def part1(y : Int32) : Int32
    rs = visible_ranges(y)
    ms = [rs.pop]
    
    # merge ranges that overlap
    until rs.empty?
      r = rs.pop
      
      # replace old range with an extended one
      ms.index { |o| r.begin <= o.end && r.end > o.end }.try do |i|
        m = ms.delete_at(i)
        ms << (m.begin..r.end)
      end
    end

    # count ranges exclude beacons
    ms.sum do |r|
      r.size - @beacons.count { |b| b[:y] == y && r.includes?(b[:x]) }
    end
  end
  
  def part2(extent : Int32) : BigInt?
    (0..extent).each do |y|
      rs = visible_ranges(y)
      x = 0

      until x > extent || rs.empty?
        r = rs.pop
        
        # advance to the end of this sensor's range
        x = r.end + 1 if r.begin <= x <= r.end
      end
      
      # solution found if all regions exhausted      
      return BigInt.new(x) * 4000000 + y if rs.empty?
    end
  end
end

day = Day15.new("data.txt")

#puts day.part1(10)
#puts day.part2(20)

puts day.part1(2000000)
puts day.part2(4000000)
