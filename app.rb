require 'green_shoes'
require 'active_support/all'

class Map
  attr_accessor :start, :goal
  delegate :[], :[]=, to: :@map

  def initialize
    @map = Array.new(10) { Array.new 10 }
    createNodes
    @start = @map[0][0]
    @end = @map[9][9]
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
  attr_accessor :location

  def initialize(location)
    @location = location
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


def a_star(map, start, goal)


end

def draw_map(map)
  xSize = app.width / map.width
  ySize = app.height / map.height

  # Draw grid
  (0...map.height).each do |y|
    line 0, y * ySize, app.width, y * ySize
  end
  (0...map.width).each do |x|
    line x * xSize, 0, x * xSize , app.height
  end
end

Shoes.app width: 600, height: 600 do
  #fill rgb(0, 0.6, 0.9, 0.1)
  #stroke rgb(0, 0.6, 0.9)
  #strokewidth 0.25

  map = Map.new

  draw_map(map)
end
