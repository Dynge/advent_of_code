defmodule Mix.Tasks.D11 do
  use Mix.Task

  def run(_args) do
    IO.puts("Advent of Code Day 11")
    stones = parse()
    IO.puts("Part 1: " <> part1(stones))
    IO.puts("Part 2: " <> part2(stones))
  end

  defp part1(stones) do
    stones |> repeat_blink(25)
  end

  defp part2(stones) do
    stones |> repeat_blink(75)
  end

  defp repeat_blink(stones, x) do
    1..x
    |> Enum.reduce(stones, fn _, stones -> blink(stones, %{}) end)
    |> Enum.reduce(0, fn {_, count}, acc -> acc + count end)
    |> Integer.to_string()
  end

  defp blink([{stone, count} | stone_tail], transformed) do
    plus = fn v -> v + count end
    update_stone = fn updated_stones, v -> updated_stones |> Map.update(v, count, plus) end

    case Integer.to_string(stone) do
      "0" ->
        blink(stone_tail, transformed |> update_stone.(1))

      x ->
        len = String.length(x)

        case len |> rem(2) do
          0 ->
            {left, right} =
              String.split_at(x, len |> div(2))
              |> then(fn {l, r} -> {String.to_integer(l), String.to_integer(r)} end)

            blink(
              stone_tail,
              transformed |> update_stone.(left) |> update_stone.(right)
            )

          _ ->
            its_christmas_damnit = 2024

            blink(
              stone_tail,
              transformed |> update_stone.(stone * its_christmas_damnit)
            )
        end
    end
  end

  defp blink([], transformed) do
    transformed |> Map.to_list()
  end

  defp parse() do
    File.read!("../data/day11.txt")
    |> String.trim_trailing()
    |> String.split(" ", trim: true)
    |> Enum.map(fn str ->
      {String.to_integer(str), 1}
    end)
  end
end
