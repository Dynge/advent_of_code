defmodule Mix.Tasks.D04 do
  use Mix.Task

  def run(_args) do
    content = File.stream!("../data/day4.txt")
    tensor = parse(content)
    p1 = part1(tensor)
    IO.inspect(p1)
    p2 = part2(tensor)
    IO.inspect(p2)
  end

  defp part1(tensor) do
    xmas_words(tensor, Complex.new(0, 0), [], 0)
  end

  defp part2(tensor) do
    xmas_cross(tensor, Complex.new(0, 0), nil, 0)
  end

  defp xmas_cross(tensor, idx, nil, cross_count) do
    {row, col} = im_parts(idx)
    {row_size, col_size} = tensor |> Nx.shape()

    IO.inspect(idx)

    cond do
      row >= row_size ->
        cross_count

      col >= col_size ->
        xmas_cross(tensor, next_row(idx), nil, cross_count)

      true ->
        case tensor |> num_at(idx) do
          ?A ->
            IO.inspect(idx)
            xmas_cross(tensor, idx, ?A, cross_count)

          _ ->
            xmas_cross(tensor, idx |> move_right(), nil, cross_count)
        end
    end
  end

  defp xmas_cross(tensor, idx, ?A, cross_count) do
    left_cross =
      [
        Complex.new(1, 1),
        Complex.new(-1, -1)
      ]
      |> Enum.map(fn dir ->
        loc = idx |> Complex.add(dir)

        if tensor |> outside_tenser?(loc) do
          nil
        else
          tensor |> num_at(loc)
        end
      end)
      |> MapSet.new()

    mas =
      MapSet.new([?M, ?S])

    right_cross =
      [
        Complex.new(-1, 1),
        Complex.new(1, -1)
      ]
      |> Enum.map(fn dir ->
        loc = idx |> Complex.add(dir)

        if tensor |> outside_tenser?(loc) do
          nil
        else
          tensor |> num_at(loc)
        end
      end)
      |> MapSet.new()

    IO.inspect(mas)

    if right_cross |> MapSet.equal?(mas) and left_cross |> MapSet.equal?(mas) do
      xmas_cross(tensor, move_right(idx), nil, cross_count + 1)
    else
      xmas_cross(tensor, move_right(idx), nil, cross_count)
    end
  end

  defp xmas_words(tensor, idx, [{:end, _}], word_count) do
    xmas_words(tensor, idx |> move_right, [], word_count)
  end

  defp xmas_words(tensor, idx, [], word_count) do
    {row, col} = im_parts(idx)
    {row_size, col_size} = tensor |> Nx.shape()

    cond do
      row >= row_size ->
        word_count

      col >= col_size ->
        xmas_words(tensor, idx |> next_row(), [], word_count)

      true ->
        case tensor |> num_at(idx) do
          ?X ->
            directions =
              [
                Complex.new(1, 1),
                Complex.new(0, 1),
                Complex.new(-1, 1),
                Complex.new(1, 0),
                Complex.new(1, -1),
                Complex.new(-1, 0),
                Complex.new(-1, -1),
                Complex.new(0, -1),
                :end
              ]
              |> Enum.map(fn dir -> {dir, [?X]} end)

            xmas_words(tensor, idx, directions, word_count)

          _ ->
            xmas_words(tensor, idx |> move_right(), [], word_count)
        end
    end
  end

  defp xmas_words(tensor, idx, [{neighbor, [?X] = matches} | rest], word_count) do
    location = Complex.add(idx, neighbor)

    if outside_tenser?(tensor, location) do
      xmas_words(tensor, idx, rest, word_count)
    else
      case tensor |> num_at(location) do
        ?M ->
          xmas_words(tensor, idx, [{neighbor, [?M | matches]} | rest], word_count)

        _ ->
          xmas_words(tensor, idx, rest, word_count)
      end
    end
  end

  defp xmas_words(tensor, idx, [{current_dir, [?M, ?X] = matches} | rest], word_count) do
    location = Complex.add(idx, Complex.multiply(current_dir, 2))

    if outside_tenser?(tensor, location) do
      xmas_words(tensor, idx, rest, word_count)
    else
      case tensor |> num_at(location) do
        ?A ->
          xmas_words(tensor, idx, [{current_dir, [?A | matches]} | rest], word_count)

        _ ->
          xmas_words(tensor, idx, rest, word_count)
      end
    end
  end

  defp xmas_words(tensor, idx, [{direction, [?A, ?M, ?X]} | rest], word_count) do
    location = Complex.add(idx, Complex.multiply(direction, 3))

    if outside_tenser?(tensor, location) do
      xmas_words(tensor, idx, rest, word_count)
    else
      case tensor |> num_at(location) do
        ?S ->
          xmas_words(tensor, idx, rest, word_count + 1)

        _ ->
          xmas_words(tensor, idx, rest, word_count)
      end
    end
  end

  defp im_parts(complex) do
    {Complex.real(complex) |> trunc(), Complex.imag(complex) |> trunc()}
  end

  defp parse(stream) do
    stream
    |> Enum.map(fn line ->
      line
      |> String.trim_trailing()
      |> to_charlist()
    end)
    |> Nx.tensor()
  end

  defp move_right(idx) do
    Complex.add(idx, Complex.new(0, 1))
  end

  defp next_row(idx) do
    Complex.new(idx |> Complex.add(1) |> Complex.real(), 0)
  end

  defp outside_tenser?(tensor, location) do
    {row, col} = im_parts(location)
    {row_size, col_size} = tensor |> Nx.shape()

    row >= row_size or col >= col_size or
      row < 0 or col < 0
  end

  defp num_at(tensor, location) do
    {row, col} = im_parts(location)
    tensor[row][col] |> Nx.to_number()
  end
end
