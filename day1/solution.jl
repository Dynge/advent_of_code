using Printf

# Import data
data = open("data.txt", "r");
food_list = readlines(data)

# Create a list of lists
food_pr_person = Vector{Vector{Int32}}([[]])

println("Part 1:")
for line ∈ food_list
  if line == ""
    # initialize the next person in the list with an empty vector
    push!(food_pr_person, [])
    continue
  end

  current_person = length(food_pr_person)
  calorie_count = parse(Int32, line)
  append!(food_pr_person[current_person], calorie_count)
end

###############################
@printf(
  "The elf carrying the most calories is carrying %s in total.\n", 
  maximum(sum, food_pr_person)
)

################################
println("Part 2:")

sum_of_each_person = map(sum, food_pr_person)
sum_of_top3 = sum(sort!(sum_of_each_person, rev=true)[1:3])

@printf(
  "The combined calories of the top 3 elves are: %s.\n",
  sum_of_top3
)
