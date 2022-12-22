alias Cmd = Int32 | Char

# face => {cx, cy}
REAL_FACE_MAP = {
  :back => {1, 0},
  :right => {2, 0},
  :top => {1, 1},
  :left => {0, 2},
  :front => {1, 2},
  :bottom => {0, 3},
}

TEST_FACE_MAP = {
  :back => {2, 0},
  :top => {2, 1},
  :front => {2, 2},
  :right => {3, 2},
  :left => {1, 1},
  :bottom => {0, 1},
}

REAL_CELL_MAP = REAL_FACE_MAP.map {|pair| {pair[1], pair[0]}}.to_h
TEST_CELL_MAP = TEST_FACE_MAP.map {|pair| {pair[1], pair[0]}}.to_h

# face => {edge => {face, edge}}
REAL_EDGE_MAP = {
  :top => {
    :left => {:left, :top},
    :right => {:right, :bottom},
    :top => {:back, :bottom},
    :bottom => {:front, :top},
  },
  :front => {
    :left => {:left, :right},
    :right => {:right, :right},
    :top => {:top, :bottom},
    :bottom => {:bottom, :right},
  },
  :left => {
    :left => {:back, :left},
    :right => {:front, :left},
    :top => {:top, :left},
    :bottom => {:bottom, :top},
  },
  :right => {
    :left => {:back, :right},
    :right => {:front, :right},
    :top => {:bottom, :bottom},
    :bottom => {:top, :right},
  },
  :back => {
    :left => {:left, :left},
    :right => {:right, :left},
    :top => {:bottom, :left},
    :bottom => {:top, :top},
  },
  :bottom => {
    :left => {:back, :top},
    :right => {:front, :bottom},
    :top => {:left, :bottom},
    :bottom => {:right, :top},
  }
}

TEST_EDGE_MAP = {
  :top => {
    :left => {:left, :right},
    :right => {:right, :top},
    :top => {:back, :bottom},
    :bottom => {:front, :top},
  },
  :front => {
    :left => {:left, :bottom},
    :right => {:right, :left},
    :top => {:top, :bottom},
    :bottom => {:bottom, :bottom},
  },
  :left => {
      :left => {:bottom, :right},
      :right => {:top, :left},
      :top => {:back, :left},
      :bottom => {:front, :left},
  },
  :right => {
    :left => {:front, :right},
    :right => {:back, :right},
    :top => {:top, :right},
    :bottom => {:bottom, :left},
  },
  :back => {
    :left => {:left, :top},
    :right => {:right, :right},
    :top => {:bottom, :top},
    :bottom => {:top, :top},
  },
  :bottom => {
    :left => {:right, :bottom},
    :right => {:left, :left},
    :top => {:back, :top},
    :bottom => {:front, :bottom},
  }
}

EDGE_MAP = REAL_EDGE_MAP
FACE_MAP = REAL_FACE_MAP
CELL_MAP = REAL_CELL_MAP

class Day22
  @cells_wide : Int32
  @cells_high : Int32

  def initialize(file : String,
                 @cell_size : Int32,
                 @edge_map : Hash(Symbol, Hash(Symbol, {Symbol, Symbol})),
                 @face_map : Hash(Symbol, {Int32, Int32}),
                 @cell_map : Hash({Int32, Int32}, Symbol))
    @map = Array(String).new
    @cmds = Array(Cmd).new
    @x_edges = Array(Range(Int32, Int32)).new
    @y_edges = Array(Range(Int32, Int32)).new

    lines = File.read_lines(file)

    # parse the map
    lines[...-2].each do |line|
      @map << line
    end

    # parse the directions
    s = lines[-1]
    i = 0

    until i == s.size
      case s[i..]
      when .match(/^\d+/); @cmds << $0.to_i; i += $0.size
      when .match(/^[A-Z]/); @cmds << $0[0]; i += $0.size
      end
    end

    # find x edges
    @map.each do |s|
      left = s.index(/[^ ]/).not_nil!
      right = s.rindex(/[^ ]/).not_nil!

      @x_edges << (left..right)
    end

    # find y edges
    (1+@x_edges.max_of &.end).times do |x|
      top, bot = @map.size, 0

      @map.each_with_index do |s, y|
        top = y if s[x]?.try {|c| c != ' '} && y < top
        bot = y if s[x]?.try {|c| c != ' '} && y > bot
      end

      @y_edges << (top..bot)
    end

    # cube cells
    @cells_wide = 1 + (@x_edges.max_of &.end) // @cell_size
    @cells_high = 1 + (@map.size // @cell_size)
  end

  def [](x : Int32, y : Int32) : Char?
    @map[y]?.try &.[x]?
  end

  def world_to_face(x : Int32, y : Int32) : {Symbol, Int32, Int32}
    cx = x // @cell_size
    cy = y // @cell_size

    # coordinates within the cell
    {@cell_map[{cx, cy}], x - cx * @cell_size, y - cy * @cell_size}
  end

  def face_to_world(face : Symbol, x : Int32, y : Int32) : {Int32, Int32}
    cx, cy = @face_map[face]
    {cx * @cell_size + x, cy * @cell_size + y}
  end

  def wrap_edge(face : Symbol, edge : Symbol, x : Int32, y : Int32) : {Symbol, Int32, Int32, Int32, Int32}
    f, new_edge = @edge_map[face][edge]
    n = @cell_size - 1

    case {edge, new_edge}
    # top edge -> ?
    when {:top, :top}; {f, n-x, 0, 0, 1}
    when {:top, :bottom}; {f, x, n, 0, -1} #ok
    when {:top, :left}; {f, 0, x, 1, 0} #ok
    when {:top, :right}; {f, n, n-x, -1, 0}

    # bottom edge -> ?
    when {:bottom, :top}; {f, x, 0, 0, 1} #ok
    when {:bottom, :bottom}; {f, n-x, n, 0, -1}
    when {:bottom, :left}; {f, 0, n-x, 1, 0} #ok
    when {:bottom, :right}; {f, n, x, -1, 0} #ok

    # left edge -> ?
    when {:left, :top}; {f, y, 0, 0, 1} #ok
    when {:left, :bottom}; {f, n-y, n, 0, -1} #ok
    when {:left, :left}; {f, 0, n-y, 1, 0} #ok
    when {:left, :right}; {f, n, y, -1, 0} #ok

    # right edge -> ?
    when {:right, :top}; {f, n-y, 0, 0, 1} #ok
    when {:right, :bottom}; {f, y, n, 0, -1} #ok
    when {:right, :left}; {f, 0, y, 1, 0} #ok
    when {:right, :right}; {f, n, n-y, -1, 0}

    # should never happen
    else raise "ACK!"
    end
  end

  def walk2d(n : Int32, x : Int32, y : Int32, dx : Int32, dy : Int32) : {Int32, Int32}
    return {x, y} if n == 0

    nx = x + dx
    ny = y + dy

    # wrap x
    nx = @x_edges[y].begin if nx > @x_edges[y].end
    nx = @x_edges[y].end if nx < @x_edges[y].begin

    # wrap y
    ny = @y_edges[x].begin if ny > @y_edges[x].end
    ny = @y_edges[x].end if ny < @y_edges[x].begin

    if self[nx, ny] == '.'
      walk2d(n-1, nx, ny, dx, dy)
    else
      {x, y} # can't move, stop here
    end
  end

  def walk3d(n : Int32, face : Symbol, x : Int32, y : Int32, dx : Int32, dy : Int32) : {Symbol, Int32, Int32, Int32, Int32}
    return {face, x, y, dx, dy} if n == 0

    org_face = face

    # move on the face
    nx = x + dx
    ny = y + dy

    # wrap edges
    face, nx, ny, ndx, ndy = wrap_edge(face, :left, x, y) if nx < 0
    face, nx, ny, ndx, ndy = wrap_edge(face, :right, x, y) if nx >= @cell_size
    face, nx, ny, ndx, ndy = wrap_edge(face, :top, x, y) if ny < 0
    face, nx, ny, ndx, ndy = wrap_edge(face, :bottom, x, y) if ny >= @cell_size

    # get the real coords
    rx, ry = face_to_world(face, nx, ny)
    #puts "#{face}@#{nx},#{ny} == #{rx},#{ry}" if self[rx, ry] == '.'

    if self[rx, ry] == '.'
      walk3d(n-1, face, nx, ny, ndx || dx, ndy || dy)
    else
      {org_face, x, y, dx, dy} # can't move, stop here
    end
  end

  def part1
    x, y, dx, dy = @x_edges[0].begin, 0, 1, 0

    @cmds.each do |cmd|
      if cmd.is_a?(Int32)
        x, y = walk2d(cmd.as(Int32), x, y, dx, dy)
      else
        case cmd
        when 'L'; dx, dy = dy, -dx
        when 'R'; dx, dy = -dy, dx
        end
      end
    end

    row = y + 1
    col = x + 1
    dir = case {dx, dy}
          when {1, 0}; 0
          when {0, 1}; 1
          when {-1, 0}; 2
          else 3
          end

    # final answer
    (1000 * row) + (4 * col) + dir
  end

  def part2
    rx, ry, dx, dy = @x_edges[0].begin, 0, 1, 0

    # convert to face coords
    face, x, y = world_to_face(rx, ry)

    @cmds.each do |cmd|
      #puts "#{face},#{x},#{y} -> #{face_to_world(face, x, y)} #{dx},#{dy} -> #{cmd}"

      if cmd.is_a?(Int32)
        face, x, y, dx, dy = walk3d(cmd.as(Int32), face, x, y, dx, dy)
      else
        case cmd
        when 'L'; dx, dy = dy, -dx
        when 'R'; dx, dy = -dy, dx
        end
      end
    end

    # convert back to world coords
    rx, ry = face_to_world(face, x, y)

    row = ry + 1
    col = rx + 1
    dir = case {dx, dy}
          when {1, 0}; 0
          when {0, 1}; 1
          when {-1, 0}; 2
          else 3
          end

    # final answer
    (1000 * row) + (4 * col) + dir
  end

  def self.test
    Day22.new("test.txt", 4, TEST_EDGE_MAP, TEST_FACE_MAP, TEST_CELL_MAP)
  end

  def self.real
    Day22.new("data.txt", 50, REAL_EDGE_MAP, REAL_FACE_MAP, REAL_CELL_MAP)
  end
end

day = Day22.real

puts day.part1
puts day.part2
