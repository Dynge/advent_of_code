defmodule Mix.Tasks.D02 do
  alias Hex.Crypto.Encryption
  use Mix.Task

  @shortdoc "Day 01 Part 1"
  def run(_args) do
    file_stream = File.stream!("../data/day2.txt")
    reports = to_reports(file_stream)
    part1(reports)
    part2(reports)
  end

  def part1(reports) do
    safe_reports =
      Enum.count(reports, fn report -> is_safe(report) end)

    IO.inspect(safe_reports)
  end

  def part2(reports) do
    safe_reports =
      Enum.count(reports, fn report ->
        damp(report, [])
      end)

    IO.inspect(safe_reports)
  end

  def to_reports(file_stream) do
    file_stream
    |> Enum.map(fn line ->
      String.split(String.trim_trailing(line), " ", trim: true)
      |> Enum.map(fn item -> String.to_integer(item) end)
    end)
  end

  defp damp([level | levels], prefix) do
    is_safe(Enum.reverse(prefix, levels)) or
      damp(levels, [level | prefix])
  end

  defp damp([], prefix) do
    is_safe(prefix)
  end

  defp is_safe([a, a | _]), do: false

  defp is_safe([a, b | _] = levels) do
    diff = a - b
    is_safe(levels, div(diff, abs(diff)))
  end

  defp is_safe(levels, sign) do
    Enum.chunk_every(levels, 2, 1)
    |> Enum.all?(fn chunks ->
      case chunks do
        [a, b] ->
          (sign * (a - b)) in 1..3

        [_] ->
          true
      end
    end)
  end
end
