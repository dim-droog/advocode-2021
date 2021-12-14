defmodule P do
  def transform_inserts(inserts) do
    for [k, v] <- inserts, into: %{}, do: {k, [String.at(k, 0) <> v, v <> String.at(k, 1)]}
  end

  def parse_raw(raw) do
    with [template | rest] = String.split(raw, "\n", trim: true),
         inserts = Enum.map(rest, &String.split(&1, " -> ")) do
      {template, transform_inserts(inserts)}
    end
  end

  def getaspairs(s) do
    with pairs =
           Enum.chunk_every(String.to_charlist(s), 2, 1, :discard) |> Enum.map(&List.to_string/1) do
      for(p <- pairs, into: %{}, do: {p, Enum.count(pairs, &(&1 == p))})
    end
  end

  def get_matching_keys(aspairs, inserts) do
    MapSet.intersection(MapSet.new(Map.keys(aspairs)), MapSet.new(Map.keys(inserts)))
  end

  def get_increments(aspairs, inserts) do
    with matching_keys = get_matching_keys(aspairs, inserts) do
      List.foldl(
        Map.to_list(inserts),
        [],
        fn {k, resulting_pairs}, acc ->
          if(Enum.member?(matching_keys, k), do: acc ++ [{k, -aspairs[k]}], else: acc) ++
            Enum.map(resulting_pairs, fn p -> {p, aspairs[k]} end)
        end
      )
      |> Enum.filter(fn {_, v} -> v != nil end)
    end
  end

  def cycle(aspairs, inserts) do
    with increments = get_increments(aspairs, inserts) do
      List.foldl(
        increments,
        aspairs,
        fn {pair, incr}, map ->
          if(Map.has_key?(map, pair),
            do: Map.update!(map, pair, &(&1 + incr)),
            else: Map.put(map, pair, incr)
          )
        end
      )
    end
  end

  def count_chars(aspairs, head, last) do
    with temp_counts =
           List.foldl(
             Map.keys(aspairs),
             %{},
             fn pair, map ->
               with chars = [String.at(pair, 0), String.at(pair, 1)] do
                 List.foldl(
                   chars,
                   map,
                   fn ch, map ->
                     Map.update(map, ch, aspairs[pair], &(&1 + aspairs[pair]))
                   end
                 )
               end
             end
           ) do
      for(
        {ch, count} <- temp_counts,
        into: %{},
        do: {ch, div(if(ch == head or ch == last, do: count + 1, else: count), 2)}
      )
    end
  end

  def get_solution(aspairs, inserts, head, last, iterations) do
    with pairs =
           List.foldl(Enum.to_list(1..iterations), aspairs, fn _, pairs ->
             cycle(pairs, inserts)
           end),
         char_counts = count_chars(pairs, head, last),
         count_values = Map.values(char_counts),
         greatest = Enum.max(count_values),
         least = Enum.min(count_values) do
      greatest - least
    end
  end
end

raw = File.read!("input.txt")
{template, inserts} = P.parse_raw(raw)
aspairs = P.getaspairs(template)
{head, last} = {String.at(template, 0), String.at(template, -1)}
IO.puts(P.get_solution(aspairs, inserts, head, last, 10))
IO.puts(P.get_solution(aspairs, inserts, head, last, 40))
