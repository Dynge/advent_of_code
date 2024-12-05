defmodule Mix.Tasks.D03 do
  use Mix.Task

  @shortdoc "Day 01 Part 1"
  def run(_args) do
    content = File.read!("../data/day3.txt")
    part1(content)
    part2(content)
  end

  def part1(content) do
    muls = Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, content)

    sum =
      muls
      |> Enum.map(fn [_, left, right] -> {String.to_integer(left), String.to_integer(right)} end)
      |> multiply()
      |> Enum.sum()

    IO.inspect(sum)
  end

  def part2(content) do
    muls = Regex.scan(~r/(mul\((\d{1,3}),(\d{1,3})\))|(do\(\))|(don't\(\))/, content)
    IO.inspect(calculate(muls, 0))
  end

  def calculate([_ | _] = matches, acc_sum) do
    {muls, remaining_matches} = matches |> next_mul([])
    calculate(remaining_matches, (muls |> multiply |> Enum.sum()) + acc_sum)
  end

  def calculate([], sum) do
    sum
  end

  def next_mul([[head | groups] | tail], acc) do
    case head do
      "do()" ->
        next_mul(tail, acc)

      "don't()" ->
        {acc, tail |> Enum.drop_while(fn [str_match | _] -> str_match != "do()" end)}

      _ ->
        [_, left, right] = groups
        next_mul(tail, [{String.to_integer(left), String.to_integer(right)} | acc])
    end
  end

  def next_mul([], acc) do
    {acc, []}
  end

  def multiply(matches) do
    matches
    |> Stream.map(fn {left, right} ->
      left * right
    end)
  end
end
