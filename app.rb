require 'green_shoes'
require 'active_support/all'
require 'algorithms'
include Containers

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
      distance = current.distance + current.distance_to(neighbor)
      guess = distance + neighbor.distance_to(goal)
      if guess < neighbor.guess
        neighbor.distance = distance
        neighbor.guess = guess
        neighbor.from = current
      end
      open_nodes.push neighbor unless open_nodes.include? neighbor
    end
  end

  # No path to goal
  return nil
end

maps = {}
maps[:empty] = Map.new
maps[:simple] = Map.new do |map|
  (2..6).each do |x|
    map[x][2].obstacle = true
    map[7][x].obstacle = true
  end
end
maps[:empty_large] = Map.new size: 100
maps[:simple_large] = Map.new size: 100 do |map|
  (20..60).each do |x|
    map[70][x].obstacle = true
  end
end
maps[:blocked] = Map.new size: 100 do |map|
  (20..70).each do |x|
    map[x][20].obstacle = true
    map[70][x].obstacle = true
  end
end
maps[:from_behind] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
  (30..70).each do |x|
    map[x][30].obstacle = true
    map[x][70].obstacle = true
    map[30][x].obstacle = true
  end
end

maps[:from_behind_double] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
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


Shoes.app width: 1000, height: 1000 do
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
    cap :curve
    strokewidth @xSize / 3
    from = node
    loop do
      node = from
      from = node.from
      break if from.nil?
      line (node.location.x + 0.5) * @xSize, (node.location.y + 0.5) * @ySize,
        (from.location.x + 0.5) * @xSize, (from.location.y + 0.5) * @ySize
    end
  end

  map = maps[:from_behind_double]
  @xSize = width / map.width
  @ySize = height / map.height

  draw_map(map)

  sleep_time = 1.0 / (map.width * map.height)
  # sleep_time = 0
  visited_callback = lambda do |visited|
    sleep sleep_time
    return if visited == map.start || visited == map.goal
    draw_node visited, red
  end

  Thread.new do
    path = a_star map, visited_callback
    alert 'No Path!' if path.nil?
    draw_path path
  end
end
