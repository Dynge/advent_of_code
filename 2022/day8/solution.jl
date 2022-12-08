function main()
  # Import data
  data = open(readlines, "./2022/day8/data.txt", "r");

  ###########
  println("Part 1:")
  vec_of_vec = map(row -> [parse(Int8, c) for c in row], data)
  forest = reduce(vcat,transpose.(vec_of_vec))

  min_cols = [min(row...) for row in eachrow(hcat(forest[1, 2:end-1], forest[end, 2:end-1]))]
  min_rows = [min(row...) for row in eachrow(hcat(forest[2:end-1, 1], forest[2:end-1, end]))]

  interior_forest = forest[2:end-1,2:end-1]


  global interior_seeable_count = 0

  for row in axes(interior_forest, 1)
    for col in axes(interior_forest, 2)
      current_tree = interior_forest[row,col]
      seeable = true

      for row_back in 1:row
        if forest[row_back,col+1] >= current_tree
          
          seeable = false
        end
      end
      if seeable
        global interior_seeable_count += 1
        continue
      end

      for row_forward in row+2:size(forest, 1)
        if forest[row_forward,col+1] >= current_tree
          
          seeable = false
        end
      end
      if seeable
        global interior_seeable_count += 1
        continue
      end

      for col_back in 1:col
        if forest[row+1,col_back] >= current_tree
          
          seeable = false
        end
      end
      if seeable
        global interior_seeable_count += 1
        continue
      end

      for col_forward in col+2:size(forest, 2)
        if forest[row+1,col_forward] >= current_tree
          
          seeable = false
        end
      end
      if seeable
        global interior_seeable_count += 1
        continue
      end
    end
  end


  return interior_seeable_count + 99 + 99 + 97 + 97


end

@time main()
