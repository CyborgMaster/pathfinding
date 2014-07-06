class StarQueue
  delegate :include?, :empty?, to: :@set

  def initialize
    @queue = PriorityQueue.new { |x, y| (x <=> y) == -1 } # Min queue
    @set = Set.new
  end

  def push(node)
    @queue.push node, node.guess
    @set.add node
  end

  def pop
    node = @queue.pop
    @set.delete node
    node
  end
end

def a_star(map, visited_callback)
  open_nodes = StarQueue.new
  closed_nodes = Set.new

  start = map.start
  goal = map.goal
  start.distance = 0
  start.guess = start.distance_to goal
  open_nodes.push start

  until open_nodes.empty?
    current = open_nodes.pop
    visited_callback.call current
    return goal if current == goal
    closed_nodes.add current
    current.neighbors.each do |neighbor|
      next if neighbor.obstacle
      next if closed_nodes.include? neighbor
      distance = current.distance + current.distance_to(neighbor)
      guess = distance + neighbor.distance_to(goal)
      if guess < neighbor.guess
        neighbor.distance = distance
        neighbor.guess = guess
        neighbor.from = current
      end
      open_nodes.push neighbor unless open_nodes.include? neighbor
    end
  end

  # No path to goal
  return nil
end
