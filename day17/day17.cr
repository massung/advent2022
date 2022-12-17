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

    # find repeating cycles {top, rock_index, wind_index} -> {i, height}
    cycles = Hash(Tuple(Int32, Int64, Int64), Array(Tuple(Int64, Int64))).new do |h, k|
      [] of {Int64, Int64}
    end

    # bottom cycle start
    cycles[{0xfe, 0_i64, 0_i64}] = [{0_i64, 0_i64}]

    while i < n + first_rock
      rock_index = i%5
      rock = ROCKS[rock_index]
      x = 2
      iy = y = height + 3
      istep = step % @wind.size

      # search for a cycle
      if stack.size > 1
        cycles[{stack[-1], rock_index, istep}]?.try do |c|
          if c.size > 2
            ia = c[-2][0] - c[-3][0]  # rocks in earlier stack
            ib = c[-1][0] - c[-2][0]  # rocks in previous stack

            rng_a = c[-3][1]...c[-2][1]
            rng_b = c[-2][1]...c[-1][1]

            if ia == ib && rng_a.size == rng_b.size && stack[rng_a] == stack[rng_b]
              puts "found cycle!"

              # calculate everything
              di = ia
              dh = rng_a.size
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
              puts "simulating remaining rocks..."

              # recurse to simulate the remainder
              return height + run(rem, rock_index, istep)
            end
          end
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

          # add the NEXT rock to the cycle cache
          cycles.update({stack[-1], (i+1)%5, step%@wind.size}) do |xs|
            xs << {i+1, height}
          end

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

day = Day17.new("test.txt")

puts day.part1
puts day.part2
