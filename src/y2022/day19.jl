module Day19

export day19

mutable struct Minerals
  ore::Int
  clay::Int
  obsidian::Int
  geode::Int
end

mutable struct Robots
  ore::Int
  clay::Int
  obsidian::Int
  geode::Int
end

mutable struct Factory
  workers::Robots
  resources::Minerals
end

function parse_blueprints()
  blueprint_strings = split(open(readchomp, "./2022/day19.txt", "r"), "\n")
  blueprint_mineral_costs = match.(
    r"Each ore robot costs (\d).+Each clay robot costs (\d).+Each obsidian robot costs (\d)\D+(\d{1,2}).+Each geode robot costs (\d)\D+(\d{1,2})",
    blueprint_strings
  )
  blueprint_buy_functions = []
  for blueprint_costs in blueprint_mineral_costs
    push!(
      blueprint_buy_functions
    )
  end
  



function day19()
end

end
