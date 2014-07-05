require 'green_shoes'
require 'active_support/all'

class Map
  delegate :[], :[]=, to: :@map

  def initialize
    @map = Array.new(10) { Array.new 10 }
  end

  def width
    @map.size
  end

  def height
    @map[0].size
  end

end

Shoes.app width: 600, height: 600 do
  #fill rgb(0, 0.6, 0.9, 0.1)
  #stroke rgb(0, 0.6, 0.9)
  #strokewidth 0.25

  map = Map.new
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
