# -*- coding: utf-8 -*-
module Maps
  class Map
    attr_reader :width, :height, :start, :goal

    def initialize(options = {})
      options = { size: 10 }.merge options
      options = { start: [0, options[:size] - 1],
        goal: [options[:size] - 1, 0] }.merge options

      @width = @height = options[:size]
      createNodes
      @start = set_start options[:start][0], options[:start][1]
      @goal = set_goal options[:goal][0], options[:goal][1]

      yield self if block_given?
    end

    def each_node
      @map.each do |col|
        col.each do |node|
          yield node
        end
      end
    end

    def createNodes
      @map = Array.new(width) { Array.new height }
      (0...width).to_a.product (0...height).to_a do |x ,y|
        @map[x][y] = Node.new(Point.new x, y)
      end

      # Hook up neighbors
      @map.each do |col|
        col.each do |node|
          loc = node.center
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
    attr_accessor :obstacle
    attr_reader :center, :neighbors

    # Used in AStar
    attr_accessor :distance, :guess, :from

    def initialize(center)
      @center = center
      @neighbors = []
      @guess = Float::INFINITY
    end

    def distance_to(other)
      center.distance_to other.center
    end
  end

  Point = Struct.new :x, :y do
    def distance_to(other)
      Math.hypot(other.x - x, other.y - y)
    end
  end

  class QuadNode < Node
    attr_reader :parent, :left, :top, :right, :bottom
    attr_reader :leaf, :nw, :ne, :sw, :se

    def initialize(left, top, right, bottom, parent = nil)
      @leaf = true
      @left, @top, @right, @bottom = left, top, right, bottom
      @parent = parent
      # puts "#{left}, #{top}, #{right}, #{bottom}"
      # puts "size: #{size}"
    end

    def size
      @size ||= (right - left + 1) * (bottom - top + 1)
    end

    def center
      @center ||= Point.new (right + left) / 2, (bottom + top) / 2
    end

    def contains?(point)
      point.x >= left && point.x <= right && point.y >= top && point.y <= bottom
    end

    def each_node(&blk)
      return blk.call self if leaf
      nw.each_node(&blk)
      ne.each_node(&blk)
      sw.each_node(&blk)
      se.each_node(&blk)
    end

    def add_item(point)
      return self if size == 1

      # Divide into 4 children
      @leaf = false
      mid = center
      @nw = QuadNode.new left, top, mid.x, mid.y, self
      @ne = QuadNode.new mid.x + 1, top, right, mid.y, self
      @sw = QuadNode.new left, mid.y + 1, mid.x, bottom, self
      @se = QuadNode.new mid.x + 1, mid.y + 1, right, bottom, self

      each_node do |child|
        return child.add_item point if child.contains? point
      end
    end
  end

  class QuadMap < Map
    def initialize(options= {})
      size = options[:size]
      fail "size must be power of 2" unless Math.log2(size) % 1 == 0
      super
    end

    def createNodes
      @root = QuadNode.new(0, 0, @width - 1, @height - 1)
    end

    def each_node(&blk)
      @root.each_node(&blk)
    end

    def add_obstacle(x, y)
      node = @root.add_item(Point.new x, y)
      node.obstacle = true
    end

    def set_start(x, y)
      @root.add_item(Point.new x, y)
    end

    def set_goal(x, y)
      @root.add_item(Point.new x, y)
    end
  end
end
