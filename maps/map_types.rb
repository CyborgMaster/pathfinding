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
    attr_reader :left, :top, :right, :bottom
    attr_reader :leaf, :top_left, :top_right, :bottom_left, :bottom_right
    attr_reader :top_neighbors, :right_neighbors, :bottom_neighbors, :left_neighbors

    def initialize(left, top, right, bottom, parent = nil)
      @leaf = true
      @left, @top, @right, @bottom = left, top, right, bottom
      @top_neighbors = Set.new
      @right_neighbors = Set.new
      @bottom_neighbors = Set.new
      @left_neighbors = Set.new
      @guess = Float::INFINITY
    end

    def size
      @size ||= width * height
    end

    def center
      @center ||= Point.new (right + left) / 2, (bottom + top) / 2
    end

    def width
      @width ||= right - left + 1
    end

    def height
      @height ||= bottom - top + 1
    end

    def contains?(point)
      point.x >= left && point.x <= right && point.y >= top && point.y <= bottom
    end

    def neighbors
      top_neighbors + right_neighbors + bottom_neighbors + left_neighbors
    end

    def each_node(&blk)
      return blk.call self if leaf
      top_left.each_node(&blk)
      top_right.each_node(&blk)
      bottom_left.each_node(&blk)
      bottom_right.each_node(&blk)
    end

    def add_item(point)
      return self if size == 1

      if leaf
        #puts "Dividing: #{self}"

        # Divide into 4 children
        @leaf = false
        @top_left = QuadNode.new left, top, center.x, center.y
        @top_right = QuadNode.new center.x + 1, top, right, center.y
        @bottom_left = QuadNode.new left, center.y + 1, center.x, bottom
        @bottom_right = QuadNode.new center.x + 1, center.y + 1, right, bottom

        # hook up neighbors
        top_left.right_neighbors << top_right
        top_left.bottom_neighbors << bottom_left

        top_right.left_neighbors << top_left
        top_right.bottom_neighbors << bottom_right

        bottom_left.right_neighbors << bottom_right
        bottom_left.top_neighbors << top_left

        bottom_right.left_neighbors << bottom_left
        bottom_right.top_neighbors << top_right

        # redistribute my neighbors
        top_neighbors.each do |neighbor|
          top_left.top_neighbors << neighbor if neighbor.left <= top_left.right
          top_right.top_neighbors << neighbor if neighbor.right >= top_right.left
        end
        right_neighbors.each do |neighbor|
          top_right.right_neighbors << neighbor if neighbor.top <= top_right.bottom
          bottom_right.right_neighbors << neighbor if neighbor.bottom >= bottom_right.top
        end
        bottom_neighbors.each do |neighbor|
          bottom_left.bottom_neighbors << neighbor if neighbor.left <= bottom_left.right
          bottom_right.bottom_neighbors << neighbor if neighbor.right >= bottom_right.left
        end
        left_neighbors.each do |neighbor|
          top_left.left_neighbors << neighbor if neighbor.top <= top_left.bottom
          bottom_left.left_neighbors << neighbor if neighbor.bottom >= bottom_right.top
        end

        # fix references to me as a neighbor
        top_neighbors.each do |neighbor|
          #puts "Top Neighbor: #{neighbor}"
          replace = []
          replace << top_left if neighbor.left <= top_left.right
          replace << top_right if neighbor.right >= top_right.left
          #puts "Replace: #{replace.map{|r| r.to_s}}"
          neighbor.bottom_neighbors.delete?(self).merge replace
          #puts "Replaced: #{neighbor.bottom_neighbors.map{|r| r.to_s}}"
        end
        right_neighbors.each do |neighbor|
          replace = []
          replace << top_right if neighbor.top <= top_right.bottom
          replace << bottom_right if neighbor.bottom >= bottom_right.top
          neighbor.left_neighbors.delete?(self).merge replace
        end
        bottom_neighbors.each do |neighbor|
          #puts "Bottom Neighbor: #{neighbor}"
          replace = []
          replace << bottom_left if neighbor.left <= bottom_left.right
          replace << bottom_right if neighbor.right >= bottom_right.left
          #puts "Replace: #{replace.map{|r| r.to_s}}"
          neighbor.top_neighbors.delete?(self).merge replace
          #puts "Replaced: #{neighbor.top_neighbors.map{|r| r.to_s}}"
        end
        left_neighbors.each do |neighbor|
          replace = []
          replace << top_left if neighbor.top <= top_left.bottom
          replace << bottom_left if neighbor.bottom >= bottom_left.top
          neighbor.right_neighbors.delete?(self).merge replace
        end

        @top_neighbors = @right_neighbors = @bottom_neighbors = @left_neighbors = nil
      end

      # pass along call to children
      each_node do |child|
        return child.add_item point if child.contains? point
      end
    end

    def to_s
      "#{left}, #{right}, #{top}, #{bottom}"
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
