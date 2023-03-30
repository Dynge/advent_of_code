module Day1

export day1

function day1()
    # Import data
    if isfile("./2022/day1.txt")
        data = open("./2022/day1.txt", "r")
        food_list = read(data, String)
        close(data)
    else
        error("File 'day1.txt' not found.")
    end

    # Create a list of lists
    separate_elves = split(chomp(food_list), "\n\n")
    food_pr_elf = map(
        elf_list -> [
            parse(Int, calorie) for calorie in split(elf_list, "\n")
        ],
        separate_elves
    )

    ###############################
    results = [maximum(sum, food_pr_elf)]

    ################################
    calorie_sum_of_each_elf = map(sum, food_pr_elf)
    sum_of_top3_elves = sum(sort!(calorie_sum_of_each_elf, rev=true)[1:3])

    push!(results, sum_of_top3_elves)
    println("Day 1 Results - ", results)
end

end
