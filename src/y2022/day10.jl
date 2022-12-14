module Day10

export day10

function day10()
  data = open(readlines, "./2022/day10.txt", "r");

  value::Int64 = 1
  cycle::Int64 = 0
  addx::Int64 = 0

  result = []

  save_cycles = 20:40:220

  ascii = ""



  next = iterate(data)
  while cycle < 240
    (command, it_step) = next
    cycle += 1
    
    if (cycle-1) % 40 in [value-1; value; value+1]
      ascii = ascii * "##"
    else
      ascii = ascii * ".."
    end
    if cycle % 40 == 0
      ascii = ascii * "\n"
    end

    if cycle in save_cycles
      push!(result, value * cycle)
    end

    if addx != 0
      value += addx
      addx = 0
      continue
    end

    if command != "noop"
      _, addx_value = split(command)
      addx = parse(Int64, addx_value)
    end

    next = iterate(data, it_step)
  end


  println(sum(result))
  println(ascii)

  
end

end
