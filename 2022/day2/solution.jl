# Import data
data = open("data.txt", "r");
strategy_data = chomp(read(data, String))

strategy_list = [
                 game_strategy
                 for game_strategy in split(strategy_data, "\n")
                ]


#################################
println("Part 1:")

function calc_round_points_1(strategy)

  points = Dict{String, Int8}(
                  "win" => 6,
                  "draw" => 3,
                  "loss" => 0,
                  "rock" => 1,
                  "paper" => 2,
                  "scissor" => 3,
                 )

  results = Dict{String, Vector{String}}(
                                 "A X" => ["draw", "rock"],
                                 "A Y" => ["win", "paper"],
                                 "A Z" => ["loss", "scissor"],
                                 "B X" => ["loss", "rock"],
                                 "B Y" => ["draw", "paper"],
                                 "B Z" => ["win", "scissor"],
                                 "C X" => ["win", "rock"],
                                 "C Y" => ["loss", "paper"],
                                 "C Z" => ["draw", "scissor"],
                                )
  return sum([points[result] for result in results[strategy]])

end

round_points = map(calc_round_points_1, strategy_list)
total_points = sum(round_points)

print(
      "Total points if the strategy is perfect in part 1: ",
      total_points,
      "\n"
    )

###########################
println("Part 2:")


function calc_round_points_2(strategy)

  points = Dict{String, Int8}(
                  "win" => 6,
                  "draw" => 3,
                  "loss" => 0,
                  "rock" => 1,
                  "paper" => 2,
                  "scissor" => 3,
                 )

  results = Dict{String, Vector{String}}(
                                 "A X" => ["loss", "scissor"],
                                 "A Y" => ["draw", "rock"],
                                 "A Z" => ["win", "paper"],
                                 "B X" => ["loss", "rock"],
                                 "B Y" => ["draw", "paper"],
                                 "B Z" => ["win", "scissor"],
                                 "C X" => ["loss", "paper"],
                                 "C Y" => ["draw", "scissor"],
                                 "C Z" => ["win", "rock"],
                                )
  return sum([points[result] for result in results[strategy]])

end

round_points = map(calc_round_points_2, strategy_list)
total_points = sum(round_points)

print(
      "Total points if the strategy is perfect in part 2: ",
      total_points,
      "\n"
    )
