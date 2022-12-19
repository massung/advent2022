alias Resources = Hash(String, Int32)
alias Robot = Hash(String, Int32)
alias Blueprint = Hash(String, Robot)
alias State = {time: Int32, res: Resources, bots: Resources}

def initial_state
  initial_bots = Resources.new(0)
  initial_bots["ore"] = 1

  {time: 0, res: Resources.new(0), bots: initial_bots}
end

SUMS = [0] + (1..100).map {|i| (1..i).sum}

class Day19
  def initialize(file : String)
    @blueprints = Array(Blueprint).new

    File.each_line(file) do |line|
      bp = Blueprint.new

      line.split(": ")[1].split(". ").each do |robot|
        robot.match(/Each (\w+) robot costs (.*)/).try do |m|
          kind = $1
          bp[kind] = Robot.new

          $2.split(" and ").each do |cost|
            cost.match(/(\d+) (\w+)/).try do |m|
              bp[kind][$2] = $1.to_i
            end
          end
        end
      end

      @blueprints << bp
    end
  end

  def skip_to(bp : Blueprint, st : State, bot : String, time_limit : Int32) : State?
    return nil unless bp[bot].keys.all? {|res| st[:bots][res] > 0}  # not possible?

    # find out many turns are needed to get the resources needed
    turns = 1 + bp[bot].max_of do |k,v|
      n = st[:res][k]

      # either have enough or divide to get turns
      n >= v ? 0 : ((v - n).to_f / st[:bots][k]).ceil.to_i
    end

    # out of time?
    return nil unless st[:time] + turns < time_limit

    # create a new state of resources and bots
    res = st[:res].dup
    bots = st[:bots].dup

    # add all the resources gained for the turns
    st[:bots].each {|k,v| res[k] += v * turns}

    # spend the resources for the new bot
    bp[bot].each {|k,v| res[k] -= v}

    # add the new bot
    bots[bot] += 1

    # build the new state
    {time: st[:time] + turns, res: res, bots: bots}
  end

  def impossible?(bp : Blueprint, time : Int32, geodes : Int32, st : State) : Bool
    time_left = time - st[:time]

    # can enough geodes be harvested in the remaining time?
    st[:res]["geode"] + st[:bots]["geode"] * time_left + SUMS[time_left] < geodes
  end

  def pathfind(bp : Blueprint, time : Int32)
    states = [initial_state]
    best = 0
    ore_per_clay = bp["clay"]["ore"]
    ore_per_obsidian = bp["obsidian"]["ore"] + bp["obsidian"]["clay"] * ore_per_clay
    ore_per_geode = bp["geode"]["ore"] + bp["geode"]["obsidian"] * ore_per_obsidian

    max_to_build = {
      "ore" => bp.max_of {|pair| pair[1]["ore"].not_nil!},
      "clay" => bp["obsidian"]["clay"].not_nil!,
      "obsidian" => bp["geode"]["obsidian"].not_nil!,
      "geode" => time,
    }

    # keep going until no more states
    until states.empty?
      st = states.sort_by! do |s|
        s[:bots]["clay"] * ore_per_clay +
        s[:bots]["obsidian"] * ore_per_obsidian +
        s[:bots]["geode"] * ore_per_geode
      end.pop

      # check for done with this path
      if st[:time] == time || impossible?(bp, time, best, st)
        if st[:res]["geode"] > best
          best = st[:res]["geode"]
          puts "#{best}   (states=#{states.size})"
        end

        # don't push any new states
        next
      end

      # determine if any states were pushed
      n = states.size

      # for every build possibility, skip to that possible state
      ["ore", "clay", "obsidian", "geode"].each do |bot|
        if st[:bots][bot] < max_to_build[bot]
          skip_to(bp, st, bot, time).try {|nst| states << nst}
        end
      end

      # if no new states added, then just collect
      if states.size == n && st[:bots]["geode"] > 0
        time_left = time - st[:time]
        geodes = st[:res]["geode"] + st[:bots]["geode"] * time_left

        # update the solution
        if geodes > best
          best = geodes
          puts "#{best}  (states=#{states.size})"
        end
      end
    end

    # best outcome
    best
  end

  def part1
    qual = 0

    @blueprints.each_with_index do |bp, i|
      geodes = pathfind(bp, 24)

      # debug spew
      puts "Blueprint #{i+1} = #{geodes} geodes"

      # sum the quality levels of the blueprints
      qual += (i + 1) * geodes
    end

    qual
  end

  def part2
    prod = 1

    @blueprints[...3].each_with_index do |bp, i|
      geodes = pathfind(bp, 32)

      # debug spew
      puts "Blueprint #{i+1} = #{geodes} geodes"

      # sum the quality levels of the blueprints
      prod *= geodes
    end

    prod
  end
end

day = Day19.new("data.txt")

puts day.part1
puts day.part2
