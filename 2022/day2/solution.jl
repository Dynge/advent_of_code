# Import data
data = open("data.txt", "r");
strategy_data = chomp(read(data, String))
close(data)

strategy_list::Vector{String} = [
                 game_strategy
                 for game_strategy in split(strategy_data, "\n")
                ]


#################################
println("Part 1:")

const POINTS = Dict{String, Int8}(
                "win" => 6,
                "draw" => 3,
                "loss" => 0,
                "rock" => 1,
                "paper" => 2,
                "scissor" => 3,
               )

const STRATEGY_GUIDE_1 = Dict{String, Vector{String}}(
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

function calc_round_points_1(strategy::String)::Int8
  return sum([POINTS[result] for result in STRATEGY_GUIDE_1[strategy]])
end

round_points::Vector{Int8} = map(calc_round_points_1, strategy_list)
total_points::Int32 = sum(round_points)

print(
      "Total points if the strategy is perfect in part 1: ",
      total_points,
      "\n"
    )

###########################
println("Part 2:")

const STRATEGY_GUIDE_2 = Dict{String, Vector{String}}(
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

function calc_round_points_2(strategy::String)::Int8
  return sum([POINTS[result] for result in STRATEGY_GUIDE_2[strategy]])
end

round_points::Vector{Int8} = map(calc_round_points_2, strategy_list)
total_points::Int32 = sum(round_points)

print(
      "Total points if the strategy is perfect in part 2: ",
      total_points,
      "\n"
    )
