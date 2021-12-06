defmodule Lanternfish do
  def cycle(map) do
    with procr = map[0],
         upd_map = for(i <- 0..7, into: %{}, do: {i, map[i + 1]}) do
      Map.merge(upd_map, %{6 => upd_map[6] + procr, 8 => procr})
    end
  end
end

{_, raw} = File.read("input.txt")
fish = String.split(String.trim(raw), ",") |> Enum.map(&String.to_integer(&1))

counts =
  List.foldl(fish, for(i <- 0..8, into: %{}, do: {i, 0}), fn d, counts ->
    Map.put(counts, d, counts[d] + 1)
  end)

counts = List.foldl(Enum.to_list(0..79), counts, fn _, counts -> Lanternfish.cycle(counts) end)
IO.puts(Enum.sum(Map.values(counts)))

counts = List.foldl(Enum.to_list(80..255), counts, fn _, counts -> Lanternfish.cycle(counts) end)
IO.puts(Enum.sum(Map.values(counts)))
