defmodule Lines do
  def hline(x1, x2, y) do
    for x <- x1..x2, do: {x, y}
  end

  def vline(y1, y2, x) do
    for y <- y1..y2, do: {x, y}
  end

  def line(x1, y1, x2, y2) do
    cond do
      y1 == y2 -> hline(x1, x2, y1)
      x1 == x2 -> vline(y1, y2, x1)
      true -> []
    end
  end

  def dline(x1, y1, x2, y2) do
    if(
      x1 == x2 or y1 == y2,
      do: [],
      else:
        with xinc = if(x1 < x2, do: 1, else: -1),
             yinc = if(y1 < y2, do: 1, else: -1) do
          for i <- 0..abs(y2 - y1), do: {x1 + i * xinc, y1 + i * yinc}
        end
    )
  end
end

{_, raw} = File.read("input.txt")

lines =
  Regex.scan(~r/(\d+),(\d+) -> (\d+),(\d+)/, raw)
  |> Enum.map(fn [_ | ss] -> Enum.map(ss, &String.to_integer(&1)) end)

map =
  List.foldl(lines, [], fn [x1, y1, x2, y2], points -> points ++ Lines.line(x1, y1, x2, y2) end)
  |> List.foldl(%{}, fn {x, y}, map -> Map.put(map, {x, y}, Map.get(map, {x, y}, 0) + 1) end)

IO.puts(Enum.count(Map.values(map), &(&1 > 1)))

map =
  List.foldl(lines, [], fn [x1, y1, x2, y2], points -> points ++ Lines.dline(x1, y1, x2, y2) end)
  |> List.foldl(map, fn {x, y}, map -> Map.put(map, {x, y}, Map.get(map, {x, y}, 0) + 1) end)

IO.puts(Enum.count(Map.values(map), &(&1 > 1)))
