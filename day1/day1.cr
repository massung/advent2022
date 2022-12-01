elves = [] of Int32
elf = 0

File.each_line("data.txt") do |line|
  unless line.empty?
    elf += line.to_i
  else
    elves << elf
    elf = 0
  end
end

puts elves.sort[-3..].sum
