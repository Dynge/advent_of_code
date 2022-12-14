module Day14

export day14

@enum Space begin
  AIR
  ROCK
  SAND
end

@enum Direction begin
  UP
  DOWN
  LEFT
  RIGHT
end

struct Line
  start_x::Int
  start_y::Int
  direction::Direction
  steps::Int
end  

function parse_input_to_matrix(location::String)
  data = open(readlines, location, "r")
  rock_lines::Vector{Line} = []
  for line in data
    positions = split(line, " -> ")
    for index in 1:length(positions)-1
      x0, y0 = map(x->parse(Int, x), split(positions[index], ","))
      x1, y1 = map(x->parse(Int, x), split(positions[index+1], ","))
      diff = [x0-x1, y0-y1]
      direction = DOWN::Direction
      if diff[1] == 0
        if diff[2] > 0
          direction = UP::Direction
        else
          direction = DOWN::Direction
        end
      else
        if diff[1] > 0
          direction = LEFT::Direction
        else
          direction = RIGHT::Direction
        end
      end
      push!(rock_lines, Line(x0+1, y0+1, direction, maximum(map(abs, diff))))
    end
  end
  
  return rock_lines
end

function create_matrix(lines::Vector{Line})
  max_x = 0
  max_y = 0
  for line in lines
    if line.start_x + line.steps > max_x
      max_x = line.start_x + line.steps
    end
    if line.start_y + line.steps > max_y
      max_y = line.start_y + line.steps
    end
  end

  return fill(AIR::Space, (max_x, max_y))
end

function draw_rocks!(matrix::Matrix{Space}, lines::Vector{Line})
  for line in lines
    if line.direction == UP::Direction
      matrix[line.start_x, line.start_y-line.steps:line.start_y] .= ROCK::Space
    elseif line.direction == DOWN::Direction
      matrix[line.start_x, line.start_y:line.start_y+line.steps] .= ROCK::Space
    elseif line.direction == LEFT::Direction
      matrix[line.start_x-line.steps:line.start_x, line.start_y] .= ROCK::Space
    elseif line.direction == RIGHT::Direction
      matrix[line.start_x:line.steps+line.steps, line.start_y] .= ROCK::Space
    end
  end

  return matrix
end

function spawn_sand!(matrix::Matrix{Space})::CartesianIndex
  spawn_sand_at = CartesianIndex(501, 1)
  matrix[spawn_sand_at] = SAND::Space
  return spawn_sand_at
end

function move_sand!(matrix::Matrix{Space}, sand_current_index::CartesianIndex)::CartesianIndex
  down = CartesianIndex(0,1)
  down_left = CartesianIndex(-1,1)
  down_right = CartesianIndex(1,1)
  new_index = sand_current_index
  println("Current: ", sand_current_index)
  try
    println("Below: ",
      matrix[sand_current_index+down_left],
      " ", 
      matrix[sand_current_index+down],
      " ", 
      matrix[sand_current_index+down_right],
    )
    if matrix[sand_current_index+down] == AIR::Space
      println("DOWN")
      matrix[sand_current_index+down] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index + down
    elseif matrix[sand_current_index+down_left] == AIR::Space
      println("DOWN_LEFT")
      matrix[sand_current_index+down_left] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index+down_left
    elseif matrix[sand_current_index+down_right] == AIR::Space
      println("DOWN_RIGHT")
      matrix[sand_current_index+down_right] = SAND::Space
      matrix[sand_current_index] = AIR::Space
      new_index = sand_current_index+down_right
    end
  catch
    println("Current: ", sand_current_index)
    matrix[sand_current_index] = AIR::Space
    new_index = CartesianIndex(0, 0)
  end
  return new_index
end




function day14()
  vector = parse_input_to_matrix("./2022/day14.txt")
  mat = create_matrix(vector)
  mat = draw_rocks!(mat, vector)
  cur_sand_position = CartesianIndex(501,1)
  prev_sand_position = CartesianIndex(501,1)
  sand_count = 0
  while true
    if cur_sand_position == CartesianIndex(0,0)
      println("SAND AWAY!!!!!!!")
      sand_count -= 1
      break
    end

    if (
        cur_sand_position == prev_sand_position
    )
      println("NEW SAND COMING!!!!!!!")
      cur_sand_position = spawn_sand!(mat)
      sand_count += 1
    end
    prev_sand_position = cur_sand_position
    cur_sand_position = move_sand!(mat, cur_sand_position)
    println("Current Outside: ", cur_sand_position)

    println(cur_sand_position)
  end
  println("Sand count: ", sand_count)
end

end
