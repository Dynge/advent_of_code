# Import data
data = open("data.txt", "r");
food_list = read(data, String)

# Create a list of lists
separate_elves = split(chomp(food_list), "\n\n")
food_pr_elf = map(
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

calorie_sum_of_each_elf = map(sum, food_pr_elf)
sum_of_top3_elves = sum(sort!(calorie_sum_of_each_elf, rev=true)[1:3])

print(
  "The combined calories of the top 3 elves are: ",
  sum_of_top3_elves,
  "\n", 
)
