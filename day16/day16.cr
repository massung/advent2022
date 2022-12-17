alias Valve = {rate: Int32, state: Bool, leads: Array(String)}
alias State = {valve: String, total: Int32, rate: Int32, time: Int32}

def score(s : State) : Int32
  s[:total] + s[:rate] * s[:time]
end

class Day16
  @paths : Set(String)

  def initialize(file : String)
    @valves = Hash(String, Valve).new
    @graph = Hash(Tuple(String, String), Int32).new

    # parse input
    File.each_line(file) do |line|
      if line.match(/Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? (.*)/)
        @valves[$1] = {rate: $2.to_i, state: false, leads: $3.split(", ")}
      end
    end

    # construct the graph of how many steps to valves
    @valves.keys.each_permutation(2) do |pair|
      @graph[{pair[0], pair[1]}] = pathfind(pair[0], pair[1]).not_nil!
    end

    # all possible destination valves
    @paths = Set(String).new(@valves.select {|k,v| v[:rate] > 0}.keys)
  end

  def pathfind(a : String, b : String)
    open = @valves[a][:leads].map {|v| {v, 1}}
    closed = Set{a}

    until open.empty?
      v, t = open.sort_by!{|x|-x[1]}.pop

      # don't go here again
      closed << v

      # reached destination? costs 1 min to open the valve
      return t if v == b

      # try next destinations
      @valves[v][:leads].each do |n|
        open << {n, t+1} unless closed.includes?(n)
      end
    end
  end

  def walk_to(s : State, to : String) : State?
    dt = @graph[{s[:valve], to}] + 1

    # update total flow
    total = s[:total] + s[:rate] * dt

    # new time and rate
    time = s[:time] - dt
    rate = s[:rate] + @valves[to][:rate]

    # new state
    {valve: to, total: total, rate: rate, time: time} if time >= 0
  end

  def part1
    initial_state = {valve: "AA", total: 0, rate: 0, time: 30}
    states = [{initial_state, @paths}]
    best_flow = 0

    until states.empty?
      s, nodes_left = states.sort_by! {|s| -s[0][:time]}.pop

      # calculate the total flow
      flow = score(s)

      # is this the best rate so far?
      if flow > best_flow
        best_flow = flow
        #puts "#{best_flow}  (#{states.size})"
      end

      nodes_left.each do |to|
        walk_to(s, to).try do |nst|
          states << {nst, nodes_left - Set{to}}
        end
      end
    end

    best_flow
  end

  def part2
    initial_state = {valve: "AA", total: 0, rate: 0, time: 26}
    states = [{initial_state, initial_state,  @paths}]
    best_flow = 0

    until states.empty?
      a, b, nodes_left = states.sort_by! {|s| -(s[0][:time]+s[1][:time])}.pop

      # calculate the total flow
      flow = score(a) + score(b)

      # is this the best rate so far?
      if flow > best_flow
        puts "#{best_flow = flow}   (#{states.size})"
      end

      # select the next set of possible paths to go to
      nodes_left.to_a.each_permutation(2) do |n|
        x, y = n[0], n[1]

        # walk from a -> x and b -> y
        walk_to(a, x).try do |na|
          walk_to(b, y).try do |nb|
            next if na[:time] < 0 || a[:time] - na[:time] > 6
            next if nb[:time] < 0 || b[:time] - nb[:time] > 6

            # push next state
            states << {na, nb, nodes_left - Set{x, y}}
          end
        end
      end
    end

    best_flow
  end
end

day = Day16.new("data.txt")

puts day.part1
puts day.part2
