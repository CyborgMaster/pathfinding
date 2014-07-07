module Maps
  MAPS = {}
  MAPS[:empty] = QuadMap.new size: 16
  MAPS[:simple] = QuadMap.new size: 16 do |map|
    (2..6).each do |x|
      map.add_obstacle x, 2
      map.add_obstacle 7, x
    end
  end
  MAPS[:empty_large] = QuadMap.new size: 128
  MAPS[:simple_large] = QuadMap.new size: 128 do |map|
    (20..60).each do |x|
      map.add_obstacle 70, x
    end
  end
  MAPS[:blocked] = QuadMap.new size: 128 do |map|
    (20..70).each do |x|
      map.add_obstacle x, 20
      map.add_obstacle 70, x
    end
  end
  MAPS[:from_behind] = QuadMap.new size: 128, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map.add_obstacle x, 30
      map.add_obstacle x, 70
      map.add_obstacle 30, x
    end
  end

  MAPS[:from_behind_double] = QuadMap.new size: 128, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map.add_obstacle x, 30
      map.add_obstacle x, 70
      map.add_obstacle 30, x
    end
    (40..60).each do |x|
      map.add_obstacle x, 40
      map.add_obstacle x, 60
      map.add_obstacle 60, x
    end
  end

  MAPS[:no_solution] =
    QuadMap.new size: 128, start: [10, 50], goal: [50, 50] do |map|
    (40..60).each do |x|
      map.add_obstacle x, 40
      map.add_obstacle x, 60
      map.add_obstacle 60, x
      map.add_obstacle 40, x
    end
  end

  MAPS[:from_behind_double_small_entry] =
    QuadMap.new size: 128, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map.add_obstacle x, 30
      map.add_obstacle x, 70
      map.add_obstacle 30, x
      map.add_obstacle 70, x unless (48..52).include? x
    end
    (40..60).each do |x|
      map.add_obstacle x, 40
      map.add_obstacle x, 60
      map.add_obstacle 60, x
      map.add_obstacle 40, x unless (48..52).include? x
    end
  end
end
