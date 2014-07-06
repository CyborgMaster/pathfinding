module Maps
  class Map
    attr_accessor :start, :goal
    delegate :[], :[]=, to: :@map

    def initialize(options = {})
      options = { size: 10 }.merge options
      options = { start: [0, options[:size] - 1],
        goal: [options[:size] - 1, 0] }.merge options

      @map = Array.new(options[:size]) { Array.new options[:size] }
      createNodes
      hookUpNeighbors
      @start = @map[options[:start][0]][options[:start][1]]
      @goal = @map[options[:goal][0]][options[:goal][1]]

      yield self if block_given?
    end

    def width
      @map.size
    end

    def height
      @map[0].size
    end

    def each_node
      @map.each do |col|
        col.each do |node|
          yield node
        end
      end
    end

    def createNodes
      (0...width).to_a.product (0...height).to_a do |x ,y|
        @map[x][y] = Node.new(Point.new x, y)
      end
    end

    def hookUpNeighbors
      @map.each do |col|
        col.each do |node|
          loc = node.location
          ((loc.x - 1)..(loc.x + 1)).to_a.product(
            ((loc.y - 1)..(loc.y + 1)).to_a) do |x, y|

            next if x < 0 || y < 0 || x >= width || y >= height
            node.neighbors << @map[x][y]
          end
        end
      end
    end
  end

  class Node
    attr_accessor :location, :obstacle, :distance, :guess, :from
    attr_reader :neighbors

    def initialize(location)
      @location = location
      @neighbors = []
      @guess = Float::INFINITY
    end

    def distance_to(other)
      location.distance_to other.location
    end
  end

  Point = Struct.new :x, :y do
    def distance_to(other)
      Math.hypot(other.x - x, other.y - y)
    end
  end

  MAPS = {}
  MAPS[:empty] = Map.new
  MAPS[:simple] = Map.new do |map|
    (2..6).each do |x|
      map[x][2].obstacle = true
      map[7][x].obstacle = true
    end
  end
  MAPS[:empty_large] = Map.new size: 100
  MAPS[:simple_large] = Map.new size: 100 do |map|
    (20..60).each do |x|
      map[70][x].obstacle = true
    end
  end
  MAPS[:blocked] = Map.new size: 100 do |map|
    (20..70).each do |x|
      map[x][20].obstacle = true
      map[70][x].obstacle = true
    end
  end
  MAPS[:from_behind] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
    end
  end

  MAPS[:from_behind_double] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
    end
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
    end
  end

  MAPS[:no_solution] =
    Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
      map[40][x].obstacle = true
    end
  end

  MAPS[:from_behind_double_small_entry] =
    Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
      map[70][x].obstacle = true
    end
    (48..52).each do |x|
      map[70][x].obstacle = false
    end
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
      map[40][x].obstacle = true
    end
    (48..52).each do |x|
      map[40][x].obstacle = false
    end
  end

end
