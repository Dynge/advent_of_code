function main()
  # Import data
  data = open("./2022/day1/data.txt", "r");
  food_list = read(data, String)
  close(data)

  # Create a list of lists
  separate_elves::Vector{String} = split(chomp(food_list), "\n\n")
  food_pr_elf::Vector{Vector{Int32}} = map(
                    elf_list -> [
                                 parse(Int32, calorie) for calorie in split(elf_list, "\n")
                                ],
                    separate_elves
                   )

  ###############################
  println("Part 1:")

  print(
    "The elf carrying the most calories is carrying: ",
    maximum(sum, food_pr_elf),
    "\n", 
  )

  ################################
  println("Part 2:")

  calorie_sum_of_each_elf::Vector{Int32} = map(sum, food_pr_elf)
  sum_of_top3_elves::Int32 = sum(sort!(calorie_sum_of_each_elf, rev=true)[1:3])

  print(
    "The combined calories of the top 3 elves are: ",
    sum_of_top3_elves,
    "\n", 
  )
end

@time main()
