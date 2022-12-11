

function load_monkeys()
  data = open(readchomp, "./2022/day11/data.txt", "r");
  monkey_strings = split(data, "\n\n")
  monkeys = []
  for monkey_string in monkey_strings
    line = split(monkey_string, "\n")

    items = collect(map(x-> parse(Int, x.match), eachmatch(r"\d+", line[2])))

    operation = match(r"= old (\+|\*) ((\d+)|(\w+))$", line[3])

    test_divide_by = parse(Int, match(r"\d+", line[4]).match)
    test_true_to = parse(Int, match(r"\d+", line[5]).match) + 1
    test_false_to = parse(Int, match(r"\d+", line[6]).match) + 1

    push!(monkeys, Monkey(items, 0, operation, test_divide_by, test_true_to, test_false_to))
  end

  return monkeys
  
end

mutable struct Monkey
  items::Vector{BigInt}
  inspected::Int64
  operation_string::RegexMatch
  test_divide::Int8
  test_true::Int8
  test_false::Int8
end

function monkey_test(monkey, item)
  return item % monkey.test_divide == 0 ? monkey.test_true : monkey.test_false
end

function monkey_shrink_item(lcm, item)
  if item > lcm
    remainder = item % lcm
    return lcm + remainder
  end

  return item
end

function monkey_operation(monkey, item)::BigInt
  string = monkey.operation_string
  captures = string.captures
  if captures[1] == "*"
    if captures[3] !== nothing
      op_val = parse(Int, captures[3])
      return item * op_val
    else
      return item^2
    end
  else captures[1] == "+"
    if captures[3] !== nothing
      op_val = parse(Int, captures[3])
      return item + op_val
    else
      return item + item
    end
  end
  return "OH NO"
end


function main()
  monkeys = load_monkeys()

  least_common_multiple = 1
  for monkey in monkeys
    least_common_multiple *= monkey.test_divide
  end

  for round in 1:1:10000
    for monkey in monkeys
      for item in monkey.items
        item = monkey_operation(monkey, item)
        item = monkey_shrink_item(least_common_multiple, item)
        monkey.inspected += 1
        throw_to = monkey_test(monkey, item)
        push!(monkeys[throw_to].items, item)
      end
      monkey.items = []
    end
  end

  sorted_monkeys = sort([monkey.inspected for monkey in monkeys])[end-1:end]
  println(sorted_monkeys)

  println(prod(sorted_monkeys))
end


@time main()
