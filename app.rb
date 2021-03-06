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

    map = Maps::MAPS[:from_behind_double_small_entry]
    @xSize = width / map.width
    @ySize = height / map.height

    draw_map(map)

    sleep_time = 0.05
    visited_callback = lambda do |visited|
      sleep sleep_time
      return if visited == map.start || visited == map.goal
      draw_node visited, Color::RED
    end

    path = AStar::search map, visited_callback
    draw_path path unless path.nil?
  end

  def draw_map(map)
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
    draw_args = node.left * @xSize, node.top * @ySize,
      node.width * @xSize, node.height * @ySize

    @graphics.setColor color
    @graphics.fillRect(*draw_args)

    # Draw outline
    @graphics.setColor Color::BLACK
    @graphics.drawRect(*draw_args)

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
      @graphics.drawLine (node.left + node.right + 1) / 2.0 * @xSize,
        (node.top + node.bottom + 1) / 2.0 * @ySize,
        (from.left + from.right + 1) / 2.0 * @xSize,
        (from.top + from.bottom + 1) / 2.0 * @ySize
    end

    @panel.repaint
  end
end

Gui.new
