class DirTree
  def initialize
    @dirs = [] of Int32
    @sizes = [] of Int32
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

  def pop_all
    until @dirs.empty?
      pop_dir
    end
  end

  def sizes
    @sizes
  end

  def total_size
    @sizes[-1]
  end
end

tree = DirTree.new

# build directory tree
File.each_line("data.txt") do |line|
  parts = line.split

  if parts[0] == "$"
    if parts[1] == "cd"
      if parts[2] == ".."
        tree.pop_dir
      else
        tree.push_dir
      end
    end
  elsif parts[0] != "dir"
    tree.add_file parts[0].to_i
  end
end

# pop all remaining dirs
tree.pop_all

# part 1
puts tree.sizes.select { |size| size <= 100000 }.sum

# part 2
size_to_delete = ((70000000 - tree.total_size) - 30000000).abs
puts tree.sizes.select { |size| size > size_to_delete }.min
