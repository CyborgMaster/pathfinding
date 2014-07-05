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
    @start = @map[0][9]
    @goal = @map[9][0]
  end

  def width
    @map.size
  end

  def height
    @map[0].size
  end

  def createNodes
    (0...width).to_a.product (0...height).to_a do |x ,y|
      @map[x][y] = Node.new(Point.new x, y)
    end
  end
end


class Node
  attr_accessor :location, :distance, :guess
  attr_reader :adjacent

  def initialize(location)
    @location = location
    @adjacent = []
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
  delegate :push, to: :@queue

  def initialize
    @queue = PriorityQueue.new
    @set = Set.new
  end
end

def a_star(map, start, goal)
  open_nodes = StarQueue.new
  closed_nodes = Set.new

  open_nodes.push start
  start.distance = 0
  start.guess = start.distance_to goal

  until open_nodes.empty?
    current = open_nodes.pop
    return goal if current == goal
    closed_nodes.add current
    current.neighbors.each do |neighbor|
      next if closed_set.include? neighbor
      guess = neighbor.distance_to goal
      open_nodes.push neighbor, guess unless open_nodes.include? neighbor
      if guess < neighbor.guess
        neighbor.guess = guess
        neighbor.from = current
      end
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

    # Draw start and end
    draw_location(map.start.location, blue)
    draw_location(map.goal.location, green)
  end

  def draw_location(location, color)
    fill color
    rect location.x * @xSize, location.y * @ySize, @xSize, @ySize
  end

  #fill rgb(0, 0.6, 0.9, 0.1)
  #stroke rgb(0, 0.6, 0.9)
  #strokewidth 0.25

  map = Map.new
  @xSize = width / map.width
  @ySize = height / map.height

  draw_map(map)
end
