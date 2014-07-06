require 'java'
require 'active_support/all'

java_import java.awt.Color
java_import java.awt.BasicStroke

require_relative 'drawing_panel'
require_relative 'maps'
require_relative 'a_star'

class Gui
  def initialize
    width = 1000
    height = 1000
    @panel = DrawingPanel.new width, height, 'Pathfinding Example'
    @graphics = @panel.graphics

    map = Maps::MAPS[:simple]
    @xSize = width / map.width
    @ySize = height / map.height

    draw_map(map)

    sleep_time = 10.0 / (map.width * map.height)
    #sleep_time = 0
    visited_callback = lambda do |visited|
      sleep sleep_time
      return if visited == map.start || visited == map.goal
      draw_node visited, Color::RED
    end

    path = AStar::search map, visited_callback
    draw_path path unless path.nil?
  end

  def draw_map(map)
    # # Draw grid
    # (0...map.height).each do |y|
    #   line 0, y * @ySize, width, y * @ySize
    # end
    # (0...map.width).each do |x|
    #   line x * @xSize, 0, x * @xSize, height
    # end

    # Draw nodes
    map.each_node do |node|
      if node.obstacle
        draw_node node, Color::BLACK
      else
        draw_node node, Color::WHITE
      end
    end

    # Draw start and end
    draw_node map.start, Color::BLUE
    draw_node map.goal, Color::GREEN
  end

  def draw_node(node, color)
    @graphics.setColor color
    @graphics.fillRect node.location.x * @xSize, node.location.y * @ySize,
      @xSize, @ySize
    @panel.repaint
  end

  def draw_path(node)
    @graphics.setColor Color::YELLOW
    @graphics.setStroke BasicStroke.new @xSize / 3, BasicStroke::CAP_ROUND,
      BasicStroke::JOIN_ROUND
    from = node
    loop do
      node = from
      from = node.from
      break if from.nil?
      @graphics.drawLine (node.location.x + 0.5) * @xSize, (node.location.y + 0.5) * @ySize,
        (from.location.x + 0.5) * @xSize, (from.location.y + 0.5) * @ySize
    end

    @panel.repaint
  end
end

Gui.new
