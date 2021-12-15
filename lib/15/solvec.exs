# elixirc solvec.exs
# elixir -e Driver.run

defmodule Chiton do
  @very_large_number 0x7FFFFFFFFFFFFFFF

  def parse_raw(raw) do
    with lines = String.split(raw, "\n", trim: true),
         w = String.length(Enum.at(lines, 0)),
         h = length(lines),
         cells =
           Enum.map(lines, &for(i <- 0..(w - 1), do: String.to_integer(String.at(&1, i))))
           |> List.flatten() do
      {cells, w, h}
    end
  end

  def to_index({_, w, h}, x, y) do
    if(x >= 0 and x < w and y >= 0 and y < h, do: y * w + x, else: nil)
  end

  def risk(grid, x, y) do
    with i = to_index(grid, x, y) do
      if(i != nil,
        do:
          with {cells, _, _} = grid do
            Enum.at(cells, i)
          end,
        else: nil
      )
    end
  end

  def get_part2_grid_risk({cells, w, h}, xx, yy) do
    with x = Integer.mod(xx, w),
         y = Integer.mod(yy, h),
         xinc = div(xx, w),
         yinc = div(yy, h) do
      Integer.mod(risk({cells, w, h}, x, y) - 1 + xinc + yinc, 9) + 1
    end
  end

  def to_part2_grid({cells, w, h}) do
    with ww = 5 * w,
         hh = 5 * h,
         cells_ =
           for(
             yy <- 0..(hh - 1),
             do: for(xx <- 0..(ww - 1), do: get_part2_grid_risk({cells, w, h}, xx, yy))
           )
           |> List.flatten() do
      {cells_, ww, hh}
    end
  end

  def to_directed_graph(grid) do
    with nesw = [{0, -1}, {1, 0}, {0, 1}, {-1, 0}],
         {_, w, h} = grid,
         edges =
           for(
             y <- 0..h,
             do:
               for(
                 x <- 0..w,
                 do:
                   List.foldl(
                     nesw,
                     [],
                     fn {xinc, yinc}, acc ->
                       acc ++
                         [
                           {to_index(grid, x, y), to_index(grid, x + xinc, y + yinc),
                            risk(grid, x + xinc, y + yinc)}
                         ]
                     end
                   )
               )
           ) do
      edges
      |> List.flatten()
      |> Enum.filter(fn {src, dst, wgh} -> src != nil and dst != nil and wgh != nil end)
    end
  end

  # {dist, visited, path, sett, current}
  def init_dijkstra(w, h, src) do
    with ubound = w * h - 1 do
      {
        for(i <- 0..ubound, do: if(i == src, do: 0, else: @very_large_number)),
        for(_ <- 0..ubound, do: false),
        for(_ <- 0..ubound, do: 0),
        MapSet.new(),
        src
      }
    end
  end

  def dijkstra(g, {dist, visited, path, sett, current}) do
    with visited_ = List.update_at(visited, current, fn _ -> true end),
         edges = Enum.filter(g, fn {src, _, _} -> src == current end),
         {sett_, dist_, path_} =
           List.foldl(
             edges,
             {sett, dist, path},
             fn {_, dst, wgh}, {sett, dist, path} ->
               if(Enum.at(visited_, dst),
                 do: {sett, dist, path},
                 else:
                   with sett_ = MapSet.put(sett, dst),
                        alt = Enum.at(dist, current) + wgh do
                     if(alt < Enum.at(dist, dst),
                       do:
                         {sett_, List.update_at(dist, dst, fn _ -> alt end),
                          List.update_at(path, dst, fn _ -> current end)},
                       else: {sett_, dist, path}
                     )
                   end
               )
             end
           ),
         sett_2 = MapSet.delete(sett_, current) do
      if(MapSet.size(sett_2) == 0,
        do: dist,
        else:
          with current_ = Enum.min_by(MapSet.to_list(sett_2), fn a -> Enum.at(dist_, a) end) do
            dijkstra(g, {dist_, visited_, path_, sett_2, current_})
          end
      )
    end
  end
end

defmodule Driver do
  def run do
    raw = File.read!("input.txt")
    grid = {_, w, h} = Chiton.parse_raw(raw)
    g = Chiton.to_directed_graph(grid)
    dist = Chiton.dijkstra(g, Chiton.init_dijkstra(w, h, 0))
    IO.puts(Enum.at(dist, w * h - 1))

    IO.puts("Deriving part2 grid...")
    grid = {_, w, h} = Chiton.to_part2_grid(grid)
    IO.puts("Generating graph...")
    g = Chiton.to_directed_graph(grid)
    IO.puts("Finding path...")
    dist = Chiton.dijkstra(g, Chiton.init_dijkstra(w, h, 0))
    # Zzz...
    IO.puts(Enum.at(dist, w * h - 1))
  end
end
