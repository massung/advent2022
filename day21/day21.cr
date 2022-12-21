alias Op = Tuple(String, Char, String)

class Expr
  def initialize(@ex : Int128 | Op)
  end

  def term! : Int128
    @ex.as(Int128)
  end

  def term? : Int128?
    @ex.as?(Int128)
  end

  def terms : Op
    @ex.as(Op)
  end
end

class Day21
  def initialize(file : String)
    @monkeys = Hash(String, Int128 | Op).new

    File.each_line(file) do |line|
      case line
      when .match(/([a-z]+): ([a-z]+) ([+*\/-]) ([a-z]+)/)
        @monkeys[$1] = {$2, $3[0], $4}
      when .match(/([a-z]+): (\d+)/)
        @monkeys[$1] = $2.to_i
      end
    end
  end

  def eval_monkeys(eval_humn : Bool) : Set(String)
    humn_deps = Set{"humn"}
    waiting = true

    while waiting
      waiting = false

      @monkeys.each do |k, v|
        if v.is_a?(Op)
          left, op, right = v

          # check for a humn dependency
          unless eval_humn
            if humn_deps.includes?(left) || humn_deps.includes?(right)
              humn_deps << k
              next
            end
          end

          x = @monkeys[left]
          y = @monkeys[right]

          if x.is_a?(Int128) && y.is_a?(Int128)
            case op
            when '+'; @monkeys[k] = x + y
            when '-'; @monkeys[k] = x - y
            when '*'; @monkeys[k] = x * y
            when '/'; @monkeys[k] = x // y
            end
          else
            waiting = true
          end
        end
      end
    end

    humn_deps
  end

  def trace(name : String) : Expr
    x = @monkeys[name]

    # literal value
    return Expr.new(x) if x.is_a?(Int128)

    # build expression
    left, op, right = x

    Expr.new({trace(left), op, trace(right)})
  end

  def part1
    eval_monkeys(true)
    @monkeys["root"]
  end

  def part2
    deps = eval_monkeys(false)

    # start with root, work the expression backwards
    m = @monkeys["root"]

    # remove the root dependency
    deps.delete("root")

    # figure out what the final result is
    left, op, right = m.as(Tuple(String, Char, String))

    if deps.includes?(left)
      n = @monkeys[right].as(Int128)
      m = left
    else
      n = @monkeys[left].as(Int128)
      m = right
    end

    puts "#{m} = #{n}"

    # backtrack the expression
    until deps.empty?
      deps.delete(m)

      # inverse expression
      left, op, right = @monkeys[m].as(Tuple(String, Char, String))

      if deps.includes?(left)
        x = @monkeys[right].as(Int128)
        m = left

        # ? `op` x = n
        case op
        when '+'; n -= x
        when '-'; n += x
        when '*'; n //= x
        when '/'; n *= x
        end
      else
        x = @monkeys[left].as(Int128)
        m = right

        # x `op` ? = n
        case op
        when '+'; n -= x
        when '-'; n = x - n
        when '*'; n //= x
        when '/'; n = x // n
        end
      end

      puts "#{m} = #{n}"
    end
  end
end

day = Day21.new("data.txt")

#puts day.part1
puts day.part2
