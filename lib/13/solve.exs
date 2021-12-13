defmodule Origami do
  def parse_raw(raw) do
    with nums =
           Regex.scan(~r/(\d+),(\d+)/, raw)
           |> Enum.map(fn [_, s, t] -> {String.to_integer(s), String.to_integer(t)} end),
         folds =
           Regex.scan(~r/fold along (x|y)=(\d+)/, raw)
           |> Enum.map(fn [_, axis, s] -> {axis, String.to_integer(s)} end) do
      {nums, folds}
    end
  end

  def plot(nums) do
    with x_max = Enum.max(for({x, _} <- nums, do: x)),
         y_max = Enum.max(for({_, y} <- nums, do: y)) do
      for(
        y <- 0..y_max,
        do: for(x <- 0..x_max, do: if(Enum.member?(nums, {x, y}), do: '#', else: '.'))
      )
      |> Enum.join("\n")
    end
  end

  def new_coord(along, c), do: 2 * along - c

  def new_point(axis, d, {x, y}) do
    with c = if(axis == "x", do: x, else: y) do
      if(
        c > d,
        do:
          with new_c = new_coord(d, c) do
            if(axis == "x", do: {new_c, y}, else: {x, new_c})
          end,
        else: {x, y}
      )
    end
  end

  def fold(nums, {axis, d}), do: Enum.map(nums, &new_point(axis, d, &1)) |> Enum.uniq()
end

{nums, folds} = Origami.parse_raw(File.read!("input.txt"))

folded_once = Origami.fold(nums, List.first(folds))
IO.puts(length(folded_once))

folded = List.foldl(folds, nums, fn fold, nums -> Origami.fold(nums, fold) end)
IO.puts(Origami.plot(folded))
