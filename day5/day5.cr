lines = File.read_lines("data.txt")

# find the empty line to delineate stacks from moves
(lines.index &.empty?).try do |delim|
  stacks = Array(Array(Char)).new(26) { Array(Char).new }

  # parse all the stacks in reverse order
  lines[...delim - 1].reverse.each do |line|
    (1..line.size).step(4).each_with_index do |c, i|
      stacks[i] << line[c] if line[c].letter?
    end
  end

  # perform all the moves
  lines[delim + 1..].each do |line|
    move = line.scan(/\d+/).map &.[0].to_i

    # how many crates, from stack -> to stack
    n = move[0]
    from = move[1] - 1
    to = move[2] - 1

    # part 1
    n.times { stacks[to] << stacks[from].pop }

    # part 2
    # stacks[to].concat(stacks[from][-n..])
    # stacks[from] = stacks[from][...-n]
  end

  # last letters
  puts ((stacks.select &.[0]?).map &.[-1]).join
end
