require 'green_shoes'
require 'active_support/all'
require 'algorithms'
include Containers

class Map
  attr_accessor :start, :goal
  delegate :[], :[]=, to: :@map

  def initialize
    @map = Array.new(10) { Array.new 10 }
    createNodes
    hookUpNeighbors
    @start = @map[0][9]
    @goal = @map[9][0]

    add_obstacles
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

  def add_obstacles
    (2..6).each do |x|
      @map[x][2].obstacle = true
      @map[7][x].obstacle = true
    end
  end
end


class Node
  attr_accessor :location, :distance, :guess, :from, :obstacle
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

class StarQueue
  delegate :include?, :empty?, to: :@set

  def initialize
    @queue = PriorityQueue.new { |x, y| (x <=> y) == -1 } # Min queue
    @set = Set.new
  end

  def push(node)
    @queue.push node, node.guess
    @set.add node
  end

  def pop
    node = @queue.pop
    @set.delete node
    node
  end
end

def a_star(map, visited_callback)
  open_nodes = StarQueue.new
  closed_nodes = Set.new

  start = map.start
  goal = map.goal
  start.distance = 0
  start.guess = start.distance_to goal
  open_nodes.push start

  until open_nodes.empty?
    current = open_nodes.pop
    visited_callback.call current
    return goal if current == goal
    closed_nodes.add current
    current.neighbors.each do |neighbor|
      next if neighbor.obstacle
      next if closed_nodes.include? neighbor
      guess = neighbor.distance_to goal
      if guess < neighbor.guess
        neighbor.guess = guess
        neighbor.from = current
      end
      open_nodes.push neighbor unless open_nodes.include? neighbor
    end
  end

  # No path to goal
  return nil
end


Shoes.app width: 600, height: 600 do
  def draw_map(map)
    # Draw grid
    (0...map.height).each do |y|
      line 0, y * @ySize, width, y * @ySize
    end
    (0...map.width).each do |x|
      line x * @xSize, 0, x * @xSize, height
    end

    # Draw obstacles
    map.each_node { |node| draw_node node, black if node.obstacle }

    # Draw start and end
    draw_node map.start, blue
    draw_node map.goal, green
  end

  def draw_node(node, color)
    fill color
    rect node.location.x * @xSize, node.location.y * @ySize, @xSize, @ySize
  end

  def draw_path(node)
    stroke yellow
    strokewidth 10
    from = node
    loop do
      node = from
      from = node.from
      break if from.nil?
      line (node.location.x + 0.5) * @xSize, (node.location.y + 0.5) * @ySize,
        (from.location.x + 0.5) * @xSize, (from.location.y + 0.5) * @ySize
    end
  end

  map = Map.new
  @xSize = width / map.width
  @ySize = height / map.height

  draw_map(map)

  visited_callback = lambda do |visited|
    sleep 0.1
    return if visited == map.start || visited == map.goal
    draw_node visited, red
  end

  Thread.new do
    path = a_star map, visited_callback
    alert 'No Path!' if path.nil?
    draw_path path
  end
end
