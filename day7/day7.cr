class DirTree
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

  def sizes
    @sizes
  end

  def total_size
    @sizes[-1]
  end
end

# walk the output
tree = DirTree.new("data.txt")

# part 1
puts tree.sizes.select { |size| size <= 100000 }.sum

# part 2
size_to_delete = ((70000000 - tree.total_size) - 30000000).abs
puts tree.sizes.select { |size| size > size_to_delete }.min
