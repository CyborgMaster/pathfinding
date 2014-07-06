module Maps
  class Map
    attr_accessor :start, :goal

    def initialize(options = {})
      options = { size: 10 }.merge options
      options = { start: [0, options[:size] - 1],
        goal: [options[:size] - 1, 0] }.merge options

      @map = Array.new(options[:size]) { Array.new options[:size] }
      createNodes
      @start = set_start options[:start][0], options[:start][1]
      @goal = set_goal options[:goal][0], options[:goal][1]

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

      # Hook up neighbors
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

    def add_obstacle(x, y)
      @map[x][y].obstacle = true
    end

    def set_start(x, y)
      @map[x][y]
    end

    def set_goal(x, y)
      @map[x][y]
    end
  end

  class Node
    attr_accessor :location, :obstacle
    attr_reader :neighbors

    # Used in AStar
    attr_accessor :distance, :guess, :from

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
end
