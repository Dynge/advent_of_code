module Day15

export day15

function load_data(location)::Vector{Tuple{Complex, Complex}}
  data = open(readlines, location, "r")
  locations = []
  for line in data
    (sensor_x, sensor_y, beacon_x, beacon_y) =  match(
      r"x=(.?\d+).+y=(.?\d+).+x=(.?\d+).+y=(.?\d+)", line
    ).captures

    push!(
      locations, (
        complex(parse(Int, sensor_x), parse(Int, sensor_y)),
        complex(parse(Int, beacon_x), parse(Int, beacon_y)),
      )
    )
  end
  
  return locations
end

manh(a::Complex, b::Complex) = abs(real(a-b)) + abs(imag(a-b))

function part1(sensors; y=2_000_000)
  covered_positions::Dict{Int, Set{Int}} = Dict([])
  covered_positions[y] = Set()
  for sensor in sensors
    distance = manh(sensor[1], sensor[2])
    x_min = min(
      real(sensor[1]) - (distance - abs(y-imag(sensor[1]))),
      real(sensor[1]) + (distance - abs(y-imag(sensor[1])))
    )
    x_max = max(
      real(sensor[1]) - (distance - abs(y-imag(sensor[1]))),
      real(sensor[1]) + (distance - abs(y-imag(sensor[1])))
    )
    for x in x_min:x_max 
      push!(covered_positions[y], x)
    end
  end

  for (sensor, beacon) in sensors
    if imag(sensor) in keys(covered_positions)
      delete!(covered_positions[imag(sensor)], real(sensor))
    end

    if imag(beacon) in keys(covered_positions)
      delete!(covered_positions[imag(beacon)], real(beacon))
    end
  end
  return length(covered_positions[y])
  
end

function part2(sensors)
  min_x = min_y = 0
  max_x = max_y = 4_000_000

  a_coefs = Set()
  b_coefs = Set()
  for sensor in sensors
    radius = manh(sensor[1], sensor[2])
    push!(a_coefs, imag(sensor[1])-real(sensor[1])+radius+1)
    push!(a_coefs, imag(sensor[1])-real(sensor[1])-radius-1)
    push!(b_coefs, real(sensor[1])+imag(sensor[1])+radius+1)
    push!(b_coefs, real(sensor[1])+imag(sensor[1])-radius-1)
  end


  for a in a_coefs
    for b in b_coefs
      intersection = complex(floor((b-a)/2), floor((a+b)/2))
      if min_x < real(intersection) < max_x && min_y < imag(intersection) < max_y
        if all([manh(intersection, sensor) > manh(sensor, beacon) for (sensor, beacon) in sensors])
          return real(intersection) * 4_000_000 + imag(intersection)
        end
      end
    end
  end
  return 0
end
  
function day15()::Vector{Int}
  sensors = load_data("./2022/day15.txt")

  return [
    part1(sensors),
    part2(sensors)
  ]
end

end
