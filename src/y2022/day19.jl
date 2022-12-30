module Day19

import Base: +, -

export day19


abstract type Cost end

struct OreCost <: Cost
  ore::Int
end
OreCost(x::SubString{String}) = OreCost(parse(Int, x))
-(x::Minerals, y::OreCost) = Minerals(x.ore - y.ore, x.clay, x.obsidian, x.geode)

struct ClayCost <: Cost
  ore::Int
end
ClayCost(x::SubString{String}) = ClayCost(parse(Int, x))
-(x::Minerals, y::ClayCost) = Minerals(x.ore - y.ore, x.clay, x.obsidian, x.geode)

struct ObsidianCost <: Cost
  ore::Int
  clay::Int
end
ObsidianCost(x::SubString{String}, y::SubString{String}) = ObsidianCost(parse(Int, x), parse(Int, y))
-(x::Minerals, y::ObsidianCost) = Minerals(x.ore - y.ore, x.clay - y.clay, x.obsidian, x.geode)

struct GeodeCost <: Cost
  ore::Int
  obsidian::Int
end
GeodeCost(x::SubString{String}, y::SubString{String}) = GeodeCost(parse(Int, x), parse(Int, y))
-(x::Minerals, y::GeodeCost) = Minerals(x.ore - y.ore, x.clay, x.obsidian - y.obsidian, x.geode)

mutable struct Minerals
  ore::Int
  clay::Int
  obsidian::Int
  geode::Int
end
-(x::Minerals, y::Minerals) = Minerals(x.ore - y.ore, x.clay - y.clay, x.obsidian - y.obsidian, x.geode - y.geode)
+(x::Minerals, y::Minerals) = Minerals(x.ore + y.ore, x.clay + y.clay, x.obsidian + y.obsidian, x.geode + y.geode)

mutable struct Robots
  ore::Int
  clay::Int
  obsidian::Int
  geode::Int
end
-(x::Robots, y::Robots) = Robots(x.ore - y.ore, x.clay - y.clay, x.obsidian - y.obsidian, x.geode - y.geode)
+(x::Robots, y::Robots) = Robots(x.ore + y.ore, x.clay + y.clay, x.obsidian + y.obsidian, x.geode + y.geode)

mutable struct Factory
  workers::Robots
  resources::Minerals
end


function buy!(factory::Factory, cost::OreCost)
  if factory.resources.ore >= cost.ore
    factory.resources.ore -= cost.ore
    return Robots(1,0,0,0)
  end
  return Robots(0,0,0,0)
end

function buy!(factory::Factory, cost::ClayCost)
  if factory.resources.ore >= cost.ore
    factory.resources.ore -= cost.ore
    return Robots(0,1,0,0)
  end
  return Robots(0,0,0,0)
end

function buy!(factory::Factory, cost::ObsidianCost)
  if factory.resources.ore >= cost.ore && factory.resources.clay >= cost.clay
    factory.resources.ore -= cost.ore
    factory.resources.clay -= cost.clay
    return Robots(0,0,1,0)
  end
  return Robots(0,0,0,0)
end

function buy!(factory::Factory, cost::GeodeCost)
  if factory.resources.ore >= cost.ore && factory.resources.obsidian >= cost.obsidian
    factory.resources.ore -= cost.ore
    factory.resources.obsidian -= cost.obsidian
    return Robots(0,0,0,1)
  end
  return Robots(0,0,0,0)
end


function collect_minerals!(factory::Factory)
  factory.resources.ore += factory.workers.ore 
  factory.resources.clay += factory.workers.clay 
  factory.resources.obsidian += factory.workers.obsidian 
  factory.resources.geode += factory.workers.geode 
end


function parse_blueprints()::Vector{Tuple{GeodeCost, ObsidianCost, ClayCost, OreCost}}
  blueprint_strings::Vector{SubString{String}} = split(open(readchomp, "./2022/day19.txt", "r"), "\n")
  blueprint_regex_matches::Vector{RegexMatch} = match.(
    r"Each ore robot costs (\d).+Each clay robot costs (\d).+Each obsidian robot costs (\d)\D+(\d{1,2}).+Each geode robot costs (\d)\D+(\d{1,2})",
    blueprint_strings
  )
  blueprint_costs = []
  for regex_matches in blueprint_regex_matches
    push!(
      blueprint_costs,
      (
        GeodeCost(regex_matches[5], regex_matches[6]),
        ObsidianCost(regex_matches[3], regex_matches[4]),
        ClayCost(regex_matches[2]),
        OreCost(regex_matches[1])
      )
    )
  end

  return blueprint_costs
end
  

function day19()
  blueprint_costs = parse_blueprints()
  results = []
  max_geode_fact = Factory(Robots(0,0,0,0), Minerals(0,0,0,0))
  for costs in blueprint_costs
    # TODO: Implement DFS
    factory = Factory(Robots(1,0,0,0), Minerals(0,0,0,0))
    queue = [factory]
    mins_elapsed = 0
    while length(queue) > 0 && mins_elapsed < 24
      cur_factory = pop!(queue)
      for i in length(costs):-1:0
        bought_robots = Robots(0,0,0,0)
        for cost in costs[begin:i]
          bought_robots += buy!(factory, cost)
        end
        if bought_robots == Robots(0,0,0,0)
          continue
        end
        cloned_fact = deepcopy(cur_factory)
        collect_minerals!(cloned_fact)
        cloned_fact.workers + bought_robots
        if cloned_fact.resources.geode > max_geode_fact.resources.geode
          max_geode_fact = cloned_fact
        end
        push!(queue, cloned_fact)
      end
      mins_elapsed += 1
    end
  end

  results
end

end
