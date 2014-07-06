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
  attr_reader :graphics

  delegate :repaint, to: :@panel

  def initialize(width, height, title = '')
    image = BufferedImage.new width, height, BufferedImage::TYPE_INT_ARGB;

    @panel = JPanel.new;
    @panel.setBackground Color::WHITE
    @panel.setPreferredSize Dimension.new(width, height)
    @panel.add JLabel.new ImageIcon.new image

    @graphics = image.getGraphics
    @graphics.setColor Color::BLACK

    frame = JFrame.new title
    frame.setResizable false
    frame.getContentPane.add @panel
    frame.pack
    frame.setVisible true
  end

  # repaint timer so that the screen will update
  #  new Timer(DELAY, this).start();

  # // used for an internal timer that keeps repainting
  # public void actionPerformed(ActionEvent e) {
  #     this.panel.repaint();
  # }

  # // set the background color of the drawing panel
  # public void setBackground(Color c) {
  #     this.panel.setBackground(c);
  # }

  # // show or hide the drawing panel on the screen
  # public void setVisible(boolean visible) {
  #     this.frame.setVisible(visible);
  # }

end
