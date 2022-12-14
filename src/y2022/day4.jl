module Day4

export day4

function contained_count(matrix::Matrix)::Int
  # Sum matrix cols
  # If absolute sum is less than two they are fully contained within
  return sum(map(col_sum -> abs(col_sum) < 2, sum(matrix, dims=1)))
end

function day4()
  # Import data
  data = open(readlines, "./2022/day4.txt", "r");

  ####################
  # Clean data -- one matrix representing the first elves and another for all the seconds elves in the cleanup pairs.
  cleanup_pairs_vector::Vector{Vector{AbstractString}} = map(x -> split(x, ","), data)
  cleanup_pairs_matrix::Matrix{AbstractString} = reduce(hcat,cleanup_pairs_vector)
  cleanup_elf_one_range::Matrix{Int8} = reduce(hcat, map(x -> parse.(Int, x), map(x -> split(x, "-"), cleanup_pairs_matrix[1,:])))
  cleanup_elf_two_range::Matrix{Int8} = reduce(hcat, map(x -> parse.(Int, x), map(x -> split(x, "-"), cleanup_pairs_matrix[2,:])))

  # Subtract the beginning number of each elf from their partners beginning number
  # Subtract the end number of each elf from their partners end number
  # Finally convert to sign value (-1, 0 or +1).
  difference_matrix = map(sign, cleanup_elf_one_range - cleanup_elf_two_range)


  results = [contained_count(difference_matrix)]

  #######################
  # Same procedure as Part 1, but instead of subtracting beginning from beginnig and end from end,
  # you subtract end from beginings.
  flipped_cleanup_elf_one_range = cleanup_elf_one_range[end:-1:1, :]
  difference_matrix_2 = map(sign, flipped_cleanup_elf_one_range - cleanup_elf_two_range)

  push!(results, contained_count(difference_matrix_2))
  println("Day 4 Results - ", results)
end

end
