defmodule Mix.Tasks.D01 do
  use Mix.Task

  @shortdoc "Day 01 Part 1"
  def run(_args) do
    {ok, data} = File.read("../data/day1.txt")
    lines = String.split(data, "\n", trim: true)
    {left, right} = into_lists(lines, [], [])
    sorted_left = Enum.sort(left)
    sorted_right = Enum.sort(right)

    IO.puts(:stderr, "Advent Of Code Day 1 - Part 1")
    part1(sorted_left, sorted_right)
    IO.puts(:stderr, "Advent Of Code Day 1 - Part 2")
    part2(sorted_left, sorted_right)
  end

  def part1(left, right) do
    diff = diffs(left, right, [])
    sum = List.foldl(diff, 0, fn d, acc -> acc + d end)
    IO.puts("Sum of diffs = #{Integer.to_string(sum)}")
  end

  def part2(left, right) do
    occurs =
      List.foldl(left, [], fn v, acc -> [find_occurences(v, right, 0) | acc] end)
      |> Enum.reverse()

    prod = prod_occur(occurs, left, 0)
    IO.puts("Product of Occurences = #{prod}")
  end

  def prod_occur([head_occ | tail_occ], [head_vals | tail_vals], acc) do
    prod = head_occ * head_vals
    prod_occur(tail_occ, tail_vals, acc + prod)
  end

  def prod_occur([], [], acc) do
    acc
  end

  def find_occurences(value, [head | tail], hits) do
    case value - head do
      0 -> find_occurences(value, tail, hits + 1)
      x when x < 0 -> hits
      x when x > 0 -> find_occurences(value, tail, hits)
    end
  end

  def find_occurences(value, [], hits) do
    hits
  end

  def diffs([head_l | tail_l], [head_r | tail_r], acc) do
    diffs(tail_l, tail_r, [abs(head_l - head_r) | acc])
  end

  def diffs([], [], acc) do
    acc
  end

  def into_lists([head | tail], left, right) do
    [left_value, right_value] = String.split(head)

    into_lists(tail, [String.to_integer(left_value) | left], [
      String.to_integer(right_value) | right
    ])
  end

  def into_lists([], left, right) do
    {left, right}
  end
end
