# The DrawingPanel class provides a simple interface for drawing persistent
# images using a Graphics object.  An internal BufferedImage object is used
# to keep track of what has been drawn.  A client of the class simply
# constructs a DrawingPanel of a particular size and then draws on it with
# the Graphics object, setting the background color if they so choose.

require 'java'

java_import java.awt.Color
java_import javax.swing.JFrame
java_import javax.swing.JPanel
java_import java.awt.image.BufferedImage
java_import javax.swing.JLabel
java_import javax.swing.ImageIcon
java_import java.awt.Dimension

class DrawingPanel
  delegate :repaint, :graphics, to: :@panel

  def initialize(width, height, title = '')
    @panel = BufferedPanel.new width, height

    frame = JFrame.new title
    frame.setResizable false
    frame.getContentPane.add @panel
    frame.pack
    frame.setVisible true
  end
end

class BufferedPanel < JPanel
  attr_reader :graphics

  def initialize(width, height)
    super()
    setBackground Color::WHITE
    setPreferredSize Dimension.new(width, height)

    @image = BufferedImage.new width, height, BufferedImage::TYPE_INT_ARGB;
    @graphics = @image.getGraphics
  end

  def paintComponent(graphics)
    super
    graphics.drawImage @image, 0, 0, nil
  end
end
