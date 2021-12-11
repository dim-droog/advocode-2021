defmodule Dumbo do
  def get_increments(i) do
    with adj_index_incr = [-11, -10, -9, -1, 1, 9, 10, 11],
         increment_filters = [
           {&(Integer.mod(&1, 10) == 0), [-11, -1, 9]},
           {&(Integer.mod(&1, 10) == 9), [-9, 1, 11]},
           {&(&1 < 10), [-11, -10, -9]},
           {&(&1 >= 90), [9, 10, 11]}
         ] do
      List.foldl(increment_filters, adj_index_incr, fn {pred, excl}, increments ->
        if(pred.(i), do: Enum.filter(increments, &(not Enum.member?(excl, &1))), else: increments)
      end)
    end
  end

  def get_adjacent(i) do
    for(incr <- get_increments(i), do: i + incr)
  end

  def incr_adjacent(grid, new_flashes) do
    # Same point may need to be increased multiple times!
    with adjacent = List.foldl(new_flashes, [], fn i, pts -> pts ++ get_adjacent(i) end) do
      List.foldl(
        adjacent,
        grid,
        fn i, grid ->
          List.update_at(grid, i, &(&1 + 1))
        end
      )
    end
  end

  def flash(grid, flashed \\ []) do
    with new_flashes =
           Enum.filter(
             Enum.to_list(0..99),
             &(Enum.at(grid, &1) > 9 and not Enum.member?(flashed, &1))
           ) do
      if(
        length(new_flashes) == 0,
        do: {Enum.map(grid, &if(&1 > 9, do: 0, else: &1)), length(flashed)},
        else: flash(incr_adjacent(grid, new_flashes), flashed ++ new_flashes)
      )
    end
  end

  def cycle(grid) do
    with incr_grid = Enum.map(grid, &(&1 + 1)) do
      flash(incr_grid)
    end
  end

  def until_all_flash(grid, cycle_count) do
    with {new_grid, flash_count} = cycle(grid) do
      if(flash_count == 100, do: cycle_count + 1, else: until_all_flash(new_grid, cycle_count + 1))
    end
  end
end

{_, raw} = File.read("input.txt")
grid = Regex.scan(~r/\d/, raw) |> List.flatten() |> Enum.map(&String.to_integer/1)

{g, total} =
  List.foldl(
    Enum.to_list(0..99),
    {grid, 0},
    fn _, {grid, total} ->
      with {new_grid, num_flashes} = Dumbo.cycle(grid) do
        {new_grid, total + num_flashes}
      end
    end
  )

IO.puts(total)
IO.puts(Dumbo.until_all_flash(g, 100))
