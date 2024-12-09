defmodule Mix.Tasks.D06 do
  use Mix.Task

  def run(_args) do
    IO.puts("Advent of Code Day 6")
    {start, blockers} = parse()
    IO.puts("Part 1: " <> part1(start, blockers))
    IO.puts("Part 2: " <> part2(""))
  end

  defp part1(cursor, blockers) do
    move({cursor, Complex.new(-1, 0)}, blockers, MapSet.new([cursor]))
    |> Enum.count()
    |> Integer.to_string()
  end

  defp part2(_) do
    ""
  end

  defp move({cursor, dir}, blocks, visited) do
    loc = cursor |> Complex.add(dir)

    if out_of_bounds(loc) == true do
      visited
    else
      case MapSet.member?(blocks, loc) do
        true ->
          move({cursor, turn_right(dir)}, blocks, visited)

        false ->
          new_visited = MapSet.put(visited, loc)
          move({loc, dir}, blocks, new_visited)
      end
    end
  end

  defp out_of_bounds(cursor) do
    {real, img} = {Complex.real(cursor), Complex.imag(cursor)}

    if real < 0 or real >= 130 or img < 0 or img >= 130 do
      true
    else
      false
    end
  end

  defp turn_right(dir) do
    ninety_in_radian = :math.pi() / -2
    rotated_dir = Complex.new(0, ninety_in_radian) |> Complex.exp() |> Complex.multiply(dir)
    Complex.new(round(Complex.real(rotated_dir)), round(Complex.imag(rotated_dir)))
  end

  defp parse() do
    blocks =
      File.read!("../data/day6.txt")
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {char, _} -> char == "#" or char == "^" end)
        |> Enum.map(fn {char, col} -> {Complex.new(row, col), char} end)
      end)
      |> Enum.into(%{})

    start =
      blocks
      |> Enum.filter(fn {_, v} -> v == "^" end)
      |> List.first()
      |> then(fn {key, _} ->
        key
      end)

    {start, blocks |> Map.delete(start) |> Map.keys() |> MapSet.new()}
  end
end
