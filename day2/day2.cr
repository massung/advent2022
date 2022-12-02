def part_1(a, b)
  case [a, b]
  when ["A", "X"]; 4 # rock rock
  when ["B", "Y"]; 5 # paper paper
  when ["C", "Z"]; 6 # scissors scissors
  when ["A", "Y"]; 8 # rock paper
  when ["B", "Z"]; 9 # paper scissors
  when ["C", "X"]; 7 # scissors rock
  when ["A", "Z"]; 3 # rock scissors
  when ["B", "X"]; 1 # paper rock
  when ["C", "Y"]; 2 # scissors paper
  else
    raise Exception.new("ACK!")
  end
end

def part_2(a, b)
  case [a, b]
  when ["A", "X"]; 3 # rock lose (scissors)
  when ["B", "Y"]; 5 # paper draw
  when ["C", "Z"]; 7 # scissors win (rock)
  when ["A", "Y"]; 4 # rock draw
  when ["B", "Z"]; 9 # paper win (scissors)
  when ["C", "X"]; 2 # scissors lose (paper)
  when ["A", "Z"]; 8 # rock win (paper)
  when ["B", "X"]; 1 # paper lose (rock)
  when ["C", "Y"]; 6 # scissors draw
  else
    raise Exception.new("ACK!")
  end
end

score = 0

File.each_line("data.txt") do |line|
  a, b = line.split(" ")
  score += part_2(a, b)
end

puts score.to_s
