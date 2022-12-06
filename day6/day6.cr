line = File.read("data.txt")

def find_marker(s : String, n : Int)
  (n...s.size).find do |i|
    ns = [0] * 26
    s[i - n...i].chars.all? do |c|
      i = c.ord - 'a'.ord

      # bust out as soon as a bucket has more than 1 character
      ns[i] += 1
      ns[i] < 2
    end
  end
end

# parts 1 and 2
puts find_marker(line, 4)
puts find_marker(line, 14)
