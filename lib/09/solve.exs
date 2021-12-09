defmodule Lava do
  @width 100
  @height 100

  def point(grid, x, y) do
    Enum.at(grid, @width * y + x)
  end

  def apply_nesw(grid, x, y, fun, default \\ true, acc \\ nil) do
    with nesw = [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}] do
      for {x, y} <- nesw,
          do:
            if(x < 0 or x >= @width or y < 0 or y >= @height,
              do: default,
              else: apply(fun, [grid, x, y, acc])
            )
    end
  end

  def islowpoint(grid, x, y) do
    with this = point(grid, x, y) do
      apply_nesw(grid, x, y, fn grid, x, y, _ -> this < point(grid, x, y) end) |> Enum.all?()
    end
  end

  def lowpoints(grid) do
    Stream.filter(
      for(y <- 0..(@height - 1), x <- 0..(@width - 1), do: {x, y}),
      fn {x, y} -> islowpoint(grid, x, y) end
    )
    |> Enum.to_list()
  end

  def getbasin(grid, x, y, basin \\ MapSet.new()) do
    with this = point(grid, x, y) do
      apply_nesw(
        grid,
        x,
        y,
        fn grid, x, y, basin ->
          if(point(grid, x, y) > this, do: getbasin(grid, x, y, basin), else: basin)
        end,
        basin,
        if(this < 9, do: MapSet.put(basin, {x, y}), else: basin)
      )
      |> List.foldl(MapSet.new(), &MapSet.union(&1, &2))
    end
  end
end

grid =
  File.stream!("input.txt")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&String.graphemes/1)
  |> Enum.map(&Enum.map(&1, fn s -> String.to_integer(s) end))
  |> List.flatten()

lowpoints = Lava.lowpoints(grid)

solution1 = Enum.sum(for {x, y} <- lowpoints, do: Lava.point(grid, x, y) + 1)
IO.puts(solution1)

basins = for {x, y} <- lowpoints, do: Lava.getbasin(grid, x, y)
basin_sizes = Enum.sort(Enum.map(basins, &MapSet.size/1), :desc)
solution2 = Enum.product(Enum.slice(basin_sizes, 0..2))
IO.puts(solution2)
