function main()
  # Import data
  data = open(readlines, "./2022/day8/data.txt", "r");

  ###########
  println("Part 1:")
  vec_of_vec = map(row -> [parse(Int8, c) for c in row], data)
  forest = reduce(vcat,transpose.(vec_of_vec))
end

@time main()
