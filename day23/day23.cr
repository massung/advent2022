class Day23
  @rows : Int32
  @cols : Int32

  def initialize(file : String)
    @elves = Set({Int32, Int32}).new
    @rows = 0
    @cols = 0

    File.read_lines(file).each_with_index do |line, row|
      @rows += 1
      @cols = line.size

      line.chars.each_with_index do |char, col|
        @elves << {row, col} if char == '#'
      end
    end
  end

  def surrounding(row : Int32, col : Int32) : Set(Symbol)
    dirs = Set(Symbol).new

    # check all 8 directions
    dirs << :w if @elves.includes?({row, col-1})
    dirs << :e if @elves.includes?({row, col+1})

    dirs << :nw if @elves.includes?({row-1, col-1})
    dirs << :n if @elves.includes?({row-1, col})
    dirs << :ne if @elves.includes?({row-1, col+1})

    dirs << :sw if @elves.includes?({row+1, col-1})
    dirs << :s if @elves.includes?({row+1, col})
    dirs << :se if @elves.includes?({row+1, col+1})

    dirs
  end

  def propose_move(turn : Int32, row : Int32, col : Int32) : {Int32, Int32}?
    dirs = surrounding(row, col)

    # do nothing if no one nearby
    return nil if dirs.empty?

    chain = [
      -> { {row-1, col} unless dirs === :nw || dirs === :n || dirs === :ne},
      -> { {row+1, col} unless dirs === :sw || dirs === :s || dirs === :se},
      -> { {row, col-1} unless dirs === :nw || dirs === :w || dirs === :sw},
      -> { {row, col+1} unless dirs === :ne || dirs === :e || dirs === :se},
    ]

    (turn..turn+3)
      .map {|i| chain[i & 3].call}
      .find {|move| !move.nil?}
  end

  def perform_moves(turn : Int32) : Int32
    moves = Hash({Int32, Int32}, {Int32, Int32}).new
    buckets = Hash({Int32, Int32}, Int32).new(0)
    elves_moved = 0

    # collect all proposed moves
    @elves.each do |elf|
      propose_move(turn, *elf).try do |move|
        moves[elf] = move
        buckets[move] += 1
      end
    end

    # move elves
    moves.each do |elf, move|
      if buckets[move] == 1
        @elves.delete elf
        @elves.add move

        # count the number of moved elves
        elves_moved += 1
      end
    end

    elves_moved
  end

  def extents : {Range(Int32, Int32), Range(Int32, Int32)}
    left = @elves.min_of {|rowcol| rowcol[1]}
    right = @elves.max_of {|rowcol| rowcol[1]}
    top = @elves.min_of {|rowcol| rowcol[0]}
    bottom = @elves.max_of {|rowcol| rowcol[0]}

    {top..bottom, left..right}
  end

  def print_map
    @rows.times do |row|
      @cols.times do |col|
        print @elves.includes?({row, col}) ? '#' : '.'
      end

      puts
    end
  end

  def part1
    10.times do |turn|
      perform_moves(turn)
    end

    # calculate the extents
    rows, cols = extents

    # solution is cells less elves
    (rows.size * cols.size) - @elves.size
  end

  def part2
    turn = 10  # left off from part 1
    elves_moved = 1

    until elves_moved == 0
      elves_moved = perform_moves(turn)
      turn += 1
    end

    puts turn
  end
end

day = Day23.new("data.txt")

puts day.part1
puts day.part2
