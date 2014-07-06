require 'java'
require 'active_support/all'

require_relative 'drawing_panel'
require_relative 'maps'
require_relative 'a_star'

Thread::abort_on_exception = true


java_import java.awt.Color
# import javax.swing.JFrame
# import javax.swing.JPanel


# class Canvas < JPanel

#     def paintComponent g

#         self.drawColorRectangles g

#     end

#     def drawColorRectangles g

#         g.setColor Color.new 125, 167, 116
#         g.fillRect 10, 15, 90, 60

#         g.setColor Color.new 42, 179, 231
#         g.fillRect 130, 15, 90, 60

#         g.setColor Color.new 70, 67, 123
#         g.fillRect 250, 15, 90, 60

#         g.setColor Color.new 130, 100, 84
#         g.fillRect 10, 105, 90, 60

#         g.setColor Color.new 252, 211, 61
#         g.fillRect 130, 105, 90, 60

#         g.setColor Color.new 241, 98, 69
#         g.fillRect 250, 105, 90, 60

#         g.setColor Color.new 217, 146, 54
#         g.fillRect 10, 195, 90, 60

#         g.setColor Color.new 63, 121, 186
#         g.fillRect 130, 195, 90, 60

#         g.setColor Color.new 31, 21, 1
#         g.fillRect 250, 195, 90, 60

#     end
# end

# class Example < JFrame

#     def initialize
#         super "Colors"

#         self.initUI
#     end

#     def initUI

#         canvas = Canvas.new
#         self.getContentPane.add canvas

#         self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
#         self.setSize 360, 300
#         self.setLocationRelativeTo nil
#         self.setVisible true
#     end
# end

# Example.new



# frame = javax.swing.JFrame.new("Window")
# frame.setDefaultCloseOperation(javax.swing.JFrame::EXIT_ON_CLOSE)
# frame.pack
# frame.setSize(1000, 1000)
# frame.setVisible(true)
# frame.graphics.setColor(java.awt.Color.cyan)
# frame.graphics.drawLine(0,0,100,100)

panel = DrawingPanel.new 1000, 1000, 'Pathfinding Example'
graphics = panel.graphics
graphics.setColor(java.awt.Color.cyan)
graphics.drawLine(0,0,100,100)


# Shoes.app width: 1000, height: 1000 do
#   def draw_map(map)
#     # # Draw grid
#     # (0...map.height).each do |y|
#     #   line 0, y * @ySize, width, y * @ySize
#     # end
#     # (0...map.width).each do |x|
#     #   line x * @xSize, 0, x * @xSize, height
#     # end

#     # Draw obstacles
#     map.each_node do |node|
#       if node.obstacle
#         draw_node node, black
#       else
#         draw_node node, white
#       end
#     end

#     # Draw start and end
#     draw_node map.start, blue
#     draw_node map.goal, green
#   end

#   def draw_node(node, color)
#     fill color
#     rect node.location.x * @xSize, node.location.y * @ySize, @xSize, @ySize
#   end

#   def draw_path(node)
#     stroke yellow
#     cap :curve
#     strokewidth @xSize / 3
#     from = node
#     loop do
#       node = from
#       from = node.from
#       break if from.nil?
#       line (node.location.x + 0.5) * @xSize, (node.location.y + 0.5) * @ySize,
#         (from.location.x + 0.5) * @xSize, (from.location.y + 0.5) * @ySize
#     end
#   end

#   map = Maps::MAPS[:from_behind_double_small_entry]
#   @xSize = width / map.width
#   @ySize = height / map.height

#   draw_map(map)

#   sleep_time = 1.0 / (map.width * map.height)
#   # sleep_time = 0
#   visited_callback = lambda do |visited|
#     sleep sleep_time
#     return if visited == map.start || visited == map.goal
#     draw_node visited, red
#   end

#   Thread.new do
#     path = AStar::search map, visited_callback
#     draw_path path unless path.nil?
#   end
# end
