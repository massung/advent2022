def parse_range(s : String)
  n = s.split('-')
  Range.new(n[0].to_i, n[1].to_i)
end

def encompasses?(a : Range, b : Range)
  a.includes?(b.begin) && a.includes?(b.end)
end

def overlaps?(a : Range, b : Range)
  a.includes?(b.begin) || a.includes?(b.end)
end

encompasses = 0
overlaps = 0

File.each_line("data.txt") do |line|
  pairs = line.split(',')

  a = parse_range(pairs[0])
  b = parse_range(pairs[1])

  if encompasses?(a, b) || encompasses?(b, a)
    encompasses += 1
  end

  if overlaps?(a, b) || overlaps?(b, a)
    overlaps += 1
  end
end

puts encompasses.to_s
puts overlaps.to_s
