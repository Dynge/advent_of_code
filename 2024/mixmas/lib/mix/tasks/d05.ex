defmodule Mix.Tasks.D05 do
  use Mix.Task

  def run(_args) do
    IO.puts("Advent of Code Day 5")
    {rules, updates} = parse()
    IO.puts("Part 1: " <> part1(rules, updates))
    IO.puts("Part 2: " <> part2(""))
  end

  defp part1(rules, updates) do
    correct_rules(updates, rules, [])
    |>
      Enum.sum()
    |> Integer.to_string()
  end

  defp part2(_) do
    ""
  end

  defp correct_rules([update | tail], rules_map, verified_updates) do
    case update_legal?(update, [], rules_map) do
      true ->
        middle =
          length(update)
          |> div(2)
          |> then(fn idx ->
            Enum.at(update, idx)
          end)

        correct_rules(tail, rules_map, [middle | verified_updates])

      false ->
        correct_rules(tail, rules_map, verified_updates)
    end
  end

  defp correct_rules([], _rules_map, verified_update) do
    verified_update
  end

  defp update_legal?([], _larger, _rules_map) do
    true
  end

  defp update_legal?([page | remain], larger, rules_map) do
    af = legal_after(page, larger, rules_map)
    before = legal_before(page, remain, rules_map)

    case af and before do
      true -> update_legal?(remain, [page | larger], rules_map)
      false -> false
    end
  end

  defp legal_before(_page, [], _rules_map) do
    true
  end

  defp legal_before(page, pages, rules_map) do
    case Map.fetch(rules_map, page) do
      {:ok, page_rules} -> pages |> Enum.all?(fn page -> Enum.member?(page_rules, page) end)
      _ -> true
    end
  end

  defp legal_after(_page, [], _rules_map) do
    true
  end

  defp legal_after(page, pages, rules_map) do
    case Map.fetch(rules_map, page) do
      {:ok, page_rules} -> pages |> Enum.all?(fn page -> not Enum.member?(page_rules, page) end)
      _ -> true
    end
  end

  defp add_to_map([{primary, secondary} | tail], map) do
    add_to_map(
      tail,
      map
      |> Map.update(primary, [secondary], fn value -> [secondary | value] end)
    )
  end

  defp add_to_map([], map) do
    map
  end

  defp parse() do
    [rules, updates] =
      File.read!("../data/day5.txt") |> String.split("\n\n")

    tuple_rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split("|", trim: true)
        |> Enum.map(fn num -> String.to_integer(num) end)
        |> List.to_tuple()
      end)
      |> add_to_map(%{})

    updates_lists =
      updates
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.trim_trailing()
        |> String.split(",", trim: true)
        |> Enum.map(fn num ->
          String.to_integer(num)
        end)
      end)

    {tuple_rules, updates_lists}
  end
end
