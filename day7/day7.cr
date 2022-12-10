class Day7
  def initialize(file : String)
    @dirs = [] of Int32
    @sizes = [] of Int32

    # build directory tree
    File.each_line(file) do |line|
      case line
      when .match(/^\$ cd \.\./); pop_dir
      when .match(/^\$ cd/)     ; push_dir
      when .match(/^\d+/)       ; add_file line.split[0].to_i
      end
    end

    # pop remaining directories
    until @dirs.empty?
      pop_dir
    end
  end

  def push_dir
    @dirs << 0
  end

  def add_file(size : Int32)
    @dirs[-1] += size
  end

  def pop_dir
    size = @dirs.pop
    @sizes << size
    @dirs[-1] += size unless @dirs.empty?
  end

  def small_dirs
    @sizes.select { |n| n <= 100000 }
  end

  def size_to_delete
    n = ((70000000 - @sizes[-1]) - 30000000).abs
    @sizes.select { |size| size > n }.min
  end
end

# walk the output
day = Day7.new("data.txt")

puts day.small_dirs.sum
puts day.size_to_delete
