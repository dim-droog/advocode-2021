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
           :array.new(
             size: 4 * (w * h - 2) - 2 * (w - 2 + (h - 2)),
             fixed: true,
             default: {nil, nil, nil}
           ),
         {edges, _} =
           List.foldl(Enum.to_list(0..h), {edges, 0}, fn y, {edges, edge_index} ->
             List.foldl(Enum.to_list(0..w), {edges, edge_index}, fn x, {edges, edge_index} ->
               List.foldl(nesw, {edges, edge_index}, fn {xinc, yinc}, {edges, edge_index} ->
                 with index = to_index(grid, x, y),
                      index_dst = to_index(grid, x + xinc, y + yinc) do
                   if(index != nil and index_dst != nil,
                     do:
                       {:array.set(
                          edge_index,
                          {index, index_dst, risk(grid, x + xinc, y + yinc)},
                          edges
                        ), edge_index + 1},
                     else: {edges, edge_index}
                   )
                 end
               end)
             end)
           end) do
      edges
    end
  end

  # {dist, visited, path, sett, current}
  def init_dijkstra(w, h, src) do
    with size = w * h do
      {
        :array.set(src, 0, :array.new(size: size, fixed: true, default: @very_large_number)),
        :array.new(size: size, fixed: true, default: false),
        :array.new(size: size, fixed: true, default: 0),
        MapSet.new(),
        src
      }
    end
  end

  def dijkstra(g, {dist, visited, path, sett, current}) do
    with visited_ = :array.set(current, true, visited),
         {sett_, dist_, path_} =
           :array.foldl(
             fn _, {src, dst, wgh}, {sett, dist, path} ->
               if(src != current or :array.get(dst, visited_),
                 do: {sett, dist, path},
                 else:
                   with sett_ = MapSet.put(sett, dst),
                        alt = :array.get(current, dist) + wgh do
                     if(alt < :array.get(dst, dist),
                       do: {sett_, :array.set(dst, alt, dist), :array.set(dst, current, path)},
                       else: {sett_, dist, path}
                     )
                   end
               )
             end,
             {sett, dist, path},
             g
           ),
         sett_2 = MapSet.delete(sett_, current) do
      if(MapSet.size(sett_2) == 0,
        do: dist,
        else:
          with current_ = Enum.min_by(MapSet.to_list(sett_2), fn a -> :array.get(a, dist_) end) do
            dijkstra(g, {dist_, visited_, path_, sett_2, current_})
          end
      )
    end
  end
end

raw = File.read!("lib/15/input.txt")
grid = {_, w, h} = Chiton.parse_raw(raw)
g = Chiton.to_directed_graph(grid)
dist = Chiton.dijkstra(g, Chiton.init_dijkstra(w, h, 0))
IO.puts(:array.get(w * h - 1, dist))

IO.puts("Deriving part2 grid...")
grid = {_, w, h} = Chiton.to_part2_grid(grid)
IO.puts("Generating graph...")
g = Chiton.to_directed_graph(grid)
IO.puts("Finding path...")
dist = Chiton.dijkstra(g, Chiton.init_dijkstra(w, h, 0))
# Zzz...
IO.puts(:array.get(w * h - 1, dist))
