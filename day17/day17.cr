require "big"

alias Rock = {bits: Array(Int32), w: Int32}
alias Cycle = {top: Int32, rock_index: Int64, istep: Int64, rocks: Int64, height: Int64}

ROCKS = [
  {bits: [0xf0], w: 4},
  {bits: [0x40, 0xe0, 0x40], w: 3},
  {bits: [0x20, 0x20, 0xe0], w: 3},
  {bits: [0x80, 0x80, 0x80, 0x80], w: 1},
  {bits: [0xc0, 0xc0], w: 2},
]

class Day17
  @wind : Array(Int32)

  def initialize(file : String)
    @wind = File.read(file).strip.chars.map {|c| c == '<' ? -1 : 1}
  end

  def isect(rock : Rock, x : Int32, y : Int64, stack : Array(Int32), height : Int64) : Bool?
    overlap = false

    rock[:bits].reverse_each do |b|
      overlap ||= y < height && (stack[y - height] & (b >> x)) > 0
      y += 1
    end

    overlap
  end

  def print_stack(stack : Array(Int32))
    stack.reverse.each do |b|
      puts b.to_s(2, precision: 8)[...7].gsub('0', '.')
    end
  end

  def run(n : Int64, first_rock : Int64, istep : Int64) : Int64
    step = istep
    i = first_rock
    height = 0_i64
    y = 0_i64
    stack = [] of Int32
    cycle = [{top: 0xfe, rock_index: first_rock, istep: istep, rocks: 0_i64, height: height}]

    while i < n + first_rock
      rock_index = i%5
      rock = ROCKS[rock_index]
      x = 2
      iy = y = height + 3
      istep = step % @wind.size

      # before we start dropping the rock, see if it's a cycle!
      if stack.size > 1 && stack[-1] == 0xfe
        top = stack[-1]
        #puts "checking for cycle... step=#{step}"

        cycle.rindex(cycle.size - 2) {|x| x[:top] == top && x[:rock_index] == rock_index && x[:istep] == istep}.try do |ix|
          puts "found cycle!"

          di = i - cycle[ix][:rocks]          # rocks in the loop
          dh = height - cycle[ix][:height]    # height of the loop
          rocks_left = n - i
          loops = rocks_left // di
          rem = rocks_left - (loops * di)

          puts "rocks in loop: #{di}"
          puts "height of loop: #{dh}"
          puts "rocks left to place: #{rocks_left}"
          puts "loops that will be placed: #{loops}"
          puts "remainder of rocks: #{rem}"
          puts "verify: #{i + (loops * di) + rem == n}"

          # all all the loops to the current height (stack needn't be updated)
          height += dh * loops

          # add all the rocks that were placed
          i += loops * di

          puts "height after loops: #{height}"
          puts "simulating remainging rocks..."

          # recurse to simulate the remainder
          return height + run(rem, rock_index, istep)
        end
      end

      ##
      ## SIMULATE
      ##

      # move until in place
      while true
        nx = x + @wind[step % @wind.size]
        step += 1

        # check to see if the wind move was possible
        x = nx if (0 <= nx <= 7 - rock[:w]) && !isect(rock, nx, y, stack, height)

        # drop and see if it should lock into place
        if y == 0 || isect(rock, x, y-1, stack, height)
          rock[:bits].reverse_each do |b|
            if y < height
              raise "ACK: #{i} #{step}" if (stack[y - height] & (b >> x)) > 0
              stack[y - height] |= (b >> x)
            else
              stack << (b >> x)
              height += 1
            end

            y += 1
          end

          # only keep the top N rows on the stack
          stack.truncate(-1000..) if stack.size > 10000

          # push cycle info for the NEXT rock
          cycle << {
            top: stack[-1],
            rock_index: (i+1)%5,
            istep: step%@wind.size,
            rocks: i+1,
            height: height,
          }

          # next rock
          break
        end

        # drop rock
        y -= 1
      end

      # next rock
      i += 1
    end

    height
  end

  def part1
    run(2022, 0, 0)
  end

  def part2
    run(1000000000000, 0, 0)
  end
end

day = Day17.new("data.txt")

puts day.part1
puts day.part2
