data = open("/home/michael/git/advent_of_code/2022/day3/data.txt", "r");
rucksack_list = readlines(data)
close(data)

#########################
println("Part 1:")

const ALPHABET::String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

function priority_of_duplicate_item(rucksack::AbstractString)::Int8
  uniq_first_compartment::SubString = rucksack[begin:Int(end/2)]
  uniq_second_compartment::SubString = rucksack[Int(end/2)+1:end]

  duplicate_items::Vector{Char} = intersect(uniq_first_compartment, uniq_second_compartment)

  if length(duplicate_items) > 1
    throw(Exception)
  end

  return findfirst(duplicate_items[1], ALPHABET)
end

print(
      "The sum of priorities are: ",
      sum(map(priority_of_duplicate_item, rucksack_list)),
      "\n"
     )

#########################
println("Part 2:")

function priority_of_groups_badge(group_rucksacks::Vector{String})::Int8
  duplicate_items = intersect(group_rucksacks...)
  
  if length(duplicate_items) > 1
    throw(Exception)
  end

  return findfirst(duplicate_items[1], ALPHABET)
end

function split_into_groups(rucksack_list::Vector{String}, group_size::Int=3)::Vector{Vector{String}}
  if length(rucksack_list) % group_size != 0
    throw(Exception)
  end

  groups::Vector{Vector{String}} = []
  for index in range(
                     start=1,
                     stop=length(rucksack_list)-(group_size-1),
                     step=group_size
                    )
    push!(groups, rucksack_list[index:index+group_size-1])
  end

  return groups
end

print(
      "The sum of group badge priorities are: ",
      sum(
          map(
              priority_of_groups_badge,
              split_into_groups(rucksack_list)
             )
         ),
      "\n"
     )