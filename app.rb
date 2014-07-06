require 'green_shoes'
require 'active_support/all'

require_relative 'map'
require_relative 'a_star'

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

  map = Maps::MAPS[:from_behind_double_small_entry]
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
    path = AStar::search map, visited_callback
    draw_path path unless path.nil?
  end
end
