require 'green_shoes'
require 'active_support/all'
require 'algorithms'

require_relative 'map'
require_relative 'a_star'

include Containers

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

maps[:no_solution] =
  Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
  (40..60).each do |x|
    map[x][40].obstacle = true
    map[x][60].obstacle = true
    map[60][x].obstacle = true
    map[40][x].obstacle = true
  end
end

maps[:from_behind_double_small_entry] =
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

Thread::abort_on_exception = true

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

  map = maps[:from_behind_double_small_entry]
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
    draw_path path unless path.nil?
  end
end
