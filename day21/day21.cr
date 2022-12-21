alias Expr = {String, Char, String}

class Day21
  def initialize(file : String)
    @monkeys = Hash(String, Int128 | Expr).new
    @graph = Hash(String, Array(String)).new { |k| Array(String).new }

    File.each_line(file) do |line|
      case line
      when .match(/([a-z]+): ([a-z]+) ([+*\/-]) ([a-z]+)/)
        @monkeys[$1] = {$2, $3[0], $4}

        # add to dependency graph
        @graph.update($2) {|xs| xs << $1}
        @graph.update($4) {|xs| xs << $1}
      when .match(/([a-z]+): (\d+)/)
        @monkeys[$1] = $2.to_i
      end
    end
  end

  def eval_monkey(name : String) : Int128
    m = @monkeys[name]

    # already evaluated
    return m if m.is_a?(Int128)

    # extract expression
    lhv, op, rhv = m.as(Expr)

    # eval left and right values
    x = eval_monkey(lhv)
    y = eval_monkey(rhv)

    # eval and cache answer
    case op
    when '+'; @monkeys[name] = x + y
    when '-'; @monkeys[name] = x - y
    when '*'; @monkeys[name] = x * y
    when '/'; @monkeys[name] = x // y
    else raise "ACK!"
    end
  end

  def find_deps(m : String) : Array(String)
    deps = @graph[m]

    # recursively find the other dependencies
    deps + deps.flat_map {|d| find_deps(d)}
  end

  def calc_humn : Int128
    q = find_deps("humn")

    # initial equation (m = "root")
    lhv, _, rhv = @monkeys[m = q.pop].as(Expr)

    # get the starting value
    n = q.includes?(lhv) ? eval_monkey(rhv) : eval_monkey(lhv)

    # walk the dependency list
    until q.empty?
      lhv, op, rhv = @monkeys[m = q.pop].as(Expr)

      # figure out which side of the equation the variable is on
      if q.includes?(lhv) || lhv == "humn"
        v = eval_monkey(rhv)
        #print "(#{m}) #{lhv} #{op} #{v} = #{n} "

        # L `op` ? = n
        case op
        when '+'; n -= v
        when '-'; n += v
        when '*'; n //= v
        when '/'; n *= v
        end
      else
        v = eval_monkey(lhv)
        #print "(#{m}) #{v} #{op} #{rhv} = #{n} "

        # ? `op` R = n
        case op
        when '+'; n -= v
        when '-'; n = v - n
        when '*'; n //= v
        when '/'; n = v // n
        end
      end
    end

    # should be the value of HUMN
    n
  end

  def part1
    eval_monkey("root")
  end

  def part2
    calc_humn
  end
end

day = Day21.new("data.txt")

# easier to solve in reverse order
puts day.part2
puts day.part1
