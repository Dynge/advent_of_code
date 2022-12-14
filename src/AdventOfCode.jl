module AdventOfCode

export run, day1, day2, day3, day4, day5, day6,
  day8, day10, day11, day12, day14, day15, day19

include("y2022/day1.jl")
include("y2022/day2.jl")
include("y2022/day3.jl")
include("y2022/day4.jl")
include("y2022/day5.jl")
include("y2022/day6.jl")
include("y2022/day8.jl")
include("y2022/day10.jl")
include("y2022/day11.jl")
include("y2022/day12.jl")
include("y2022/day14.jl")
include("y2022/day15.jl")
include("y2022/day19.jl")

using .Day1
using .Day2
using .Day3
using .Day4
using .Day5
using .Day6
using .Day8
using .Day10
using .Day11
using .Day12
using .Day14
using .Day15
using .Day19

function run()
  day1()
  day2()
  day3()
  day4()
  day5()
  day6()
  day8()
  day10()
  day11()
  day12()
  day14()
  println("Day 15 Results - ", day15())
  println("Day 19 Results - ", day19())
end

end
