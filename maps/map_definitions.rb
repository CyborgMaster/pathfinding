module Maps
  MAPS = {}
  MAPS[:empty] = Map.new
  MAPS[:simple] = Map.new do |map|
    (2..6).each do |x|
      map[x][2].obstacle = true
      map[7][x].obstacle = true
    end
  end
  MAPS[:empty_large] = Map.new size: 100
  MAPS[:simple_large] = Map.new size: 100 do |map|
    (20..60).each do |x|
      map[70][x].obstacle = true
    end
  end
  MAPS[:blocked] = Map.new size: 100 do |map|
    (20..70).each do |x|
      map[x][20].obstacle = true
      map[70][x].obstacle = true
    end
  end
  MAPS[:from_behind] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
    end
  end

  MAPS[:from_behind_double] = Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
    end
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
    end
  end

  MAPS[:no_solution] =
    Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
      map[40][x].obstacle = true
    end
  end

  MAPS[:from_behind_double_small_entry] =
    Map.new size: 100, start: [10, 50], goal: [50, 50] do |map|
    (30..70).each do |x|
      map[x][30].obstacle = true
      map[x][70].obstacle = true
      map[30][x].obstacle = true
      map[70][x].obstacle = true
    end
    (48..52).each do |x|
      map[70][x].obstacle = false
    end
    (40..60).each do |x|
      map[x][40].obstacle = true
      map[x][60].obstacle = true
      map[60][x].obstacle = true
      map[40][x].obstacle = true
    end
    (48..52).each do |x|
      map[40][x].obstacle = false
    end
  end
end
