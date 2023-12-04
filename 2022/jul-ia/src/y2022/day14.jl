module Day14

export day14

@enum Space begin
  AIR
  ROCK
  SAND
end

struct Line
  x0::Int
  y0::Int
  x1::Int
  y1::Int
end  


function parse_input_to_matrix(location::String)
  data = open(readlines, location, "r")
  rock_lines::Vector{Line} = []
  for line in data
    positions = split(line, " -> ")
    for index in 1:length(positions)-1
      x0, y0 = map(x->parse(Int, x), split(positions[index], ","))
      x1, y1 = map(x->parse(Int, x), split(positions[index+1], ","))
      push!(rock_lines, Line(x0+1, y0+1, x1+1, y1+1))
    end
  end
  
  return rock_lines
end

function draw_rocks!(matrix::Matrix{Space}, lines::Vector{Line}; floor_at = false)
  for line in lines
    min_y = min(line.y0, line.y1)
    min_x = min(line.x0, line.x1)
    max_y = max(line.y0, line.y1)
    max_x = max(line.x0, line.x1)
    matrix[min_y:max_y, min_x:max_x] .= ROCK::Space
  end

  if floor_at
    matrix[end, 1:end] .= ROCK::Space
  end

  return matrix
end

function spawn_sand!(matrix::Matrix{Space}; point = CartesianIndex(1, 501))::CartesianIndex
  matrix[point] = SAND::Space
  return point
end

function move_sand!(matrix::Matrix{Space}, sand_current_index::CartesianIndex)::CartesianIndex
  down = CartesianIndex(1,0)
  down_left = CartesianIndex(1,-1)
  down_right = CartesianIndex(1,1)
  new_index = sand_current_index
  try
    if matrix[sand_current_index+down] == AIR::Space
      matrix[sand_current_index+down] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index + down
    elseif matrix[sand_current_index+down_left] == AIR::Space
      matrix[sand_current_index+down_left] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index+down_left
    elseif matrix[sand_current_index+down_right] == AIR::Space
      matrix[sand_current_index+down_right] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index+down_right
    end
  catch
    matrix[sand_current_index] = AIR::Space
    new_index = CartesianIndex(0, 0)
  end
  return new_index
end




function day14()
  vector = parse_input_to_matrix("./2022/day14.txt")
  height = foldl((acc, line) -> max(acc, line.y0, line.y1), vector, init=0)
  width = foldr((line, acc) -> max(acc, line.x0, line.x1), vector, init=0)
  mat = fill(AIR::Space, (height, width))
  mat = draw_rocks!(mat, vector)
  cur_sand_position = CartesianIndex(1, 501)
  prev_sand_position = CartesianIndex(1, 501)
  sand_count = 0
  while true
    if cur_sand_position == CartesianIndex(0,0)
      sand_count -= 1
      break
    end

    if cur_sand_position == prev_sand_position
      cur_sand_position = spawn_sand!(mat)
      sand_count += 1
    end
    prev_sand_position = cur_sand_position
    cur_sand_position = move_sand!(mat, cur_sand_position)

  end

  results = [sand_count]


  # Part 2
  mat = fill(AIR::Space, (height + 2, width*2))
  mat = draw_rocks!(mat, vector, floor_at=true)
  cur_sand_position = CartesianIndex(0, 0)
  prev_sand_position = CartesianIndex(0, 0)
  sand_count = 0
  while true
    if cur_sand_position == CartesianIndex(1,501)
      break
    end

    if cur_sand_position == prev_sand_position
      cur_sand_position = spawn_sand!(mat)
      sand_count += 1
    end
    prev_sand_position = cur_sand_position
    cur_sand_position = move_sand!(mat, cur_sand_position)

  end
  push!(results, sand_count)

  println("Day 14 Results - ", results)
end

end
