module Day8

using IterTools

export day8

function day8()
  # Import data
  data = open(readlines, "./2022/day8.txt", "r");

  ###########
  vec_of_vec = map(row -> [parse(Int8, c) for c in row], data)
  forest = reduce(vcat,transpose.(vec_of_vec))

  interior_forest = forest[2:end-1,2:end-1]


  interior_seeable_count = 0
  for row in axes(interior_forest, 1)
    for col in axes(interior_forest, 2)
      current_tree = interior_forest[row,col]
      interior_seeable_count +=  can_see(current_tree, (row+1, col+1), forest)
    end
  end

  results = [interior_seeable_count + 99 + 99 + 97 + 97]

  ############

  scores::Vector{Int64} = [0]
  for row in axes(interior_forest, 1)
    for col in axes(interior_forest, 2)
      current_tree = interior_forest[row,col]
      push!(scores, scenic_score(current_tree, (row+1, col+1), forest))
    end
  end

  push!(results, maximum(scores))
  println("Day 8 Results - ", results)

end

function can_see(tree, position, forest)
  up = forest[position[1], 1:position[2]-1] .< tree
  down = forest[position[1], position[2]+1:end] .< tree
  left = forest[1:position[1]-1, position[2]] .< tree
  right = forest[position[1]+1:end, position[2]] .< tree

  return any([all(down), all(up), all(left), all(right)])
end


function scenic_score(tree, position, forest)
  up = 
    collect(
      takewhile(neighbor_tree -> neighbor_tree < tree, forest[position[1], position[2]-1:-1:1])
    )
  down = 
    collect(
      takewhile(neighbor_tree -> neighbor_tree < tree,forest[position[1], position[2]+1:end])
    )
  left = 
    collect(
      takewhile(neighbor_tree -> neighbor_tree < tree, forest[position[1]-1:-1:1, position[2]])
    )
  right = 
    collect(
      takewhile(neighbor_tree -> neighbor_tree < tree,forest[position[1]+1:end, position[2]])
    )

  score = 1

  if length(up) ==  position[2] - 1
    score *= length(up)
  else
    score *= length(up) + 1
  end

  if length(down) == size(forest, 2) - position[2]
    score *= length(down)
  else
    score *= length(down) + 1
  end
  if length(left) == position[1] - 1
    score *= length(left)
  else
    score *= length(left) + 1
  end
  if length(right) == size(forest, 1) - position[1]
    score *= length(right)
  else
    score *= length(right) + 1
  end


  return score
end

end
