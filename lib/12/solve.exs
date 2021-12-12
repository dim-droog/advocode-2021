defmodule Cave do
  def parse_raw(s) do
    String.split(s, "\n", trim: true) |> Enum.map(&String.split(&1, "-"))
  end

  def get_destinations(cave, node) do
    with nodes = Enum.filter(cave, &Enum.member?(&1, node)) do
      List.flatten(nodes)
      |> Enum.uniq()
      |> Enum.filter(&(not Enum.member?(["start", node], &1)))
    end
  end

  def find_paths(cave, node, path, allowed_twice \\ nil)

  def find_paths(_cave, "end", path, _allowed_twice) do
    [path ++ ["end"]]
  end

  def find_paths(cave, node, path, allowed_twice) do
    with dests = get_destinations(cave, node),
         allowed_dests =
           Enum.filter(dests, fn t ->
             cond do
               String.upcase(t) == t -> true
               not Enum.member?(path, t) -> true
               t == allowed_twice and Enum.count(path, &(&1 == t)) == 1 -> true
               true -> false
             end
           end),
         new_path = path ++ [node] do
      List.foldl(
        allowed_dests,
        [],
        fn t, paths ->
          paths ++ find_paths(cave, t, new_path, allowed_twice)
        end
      )
    end
  end

  def get_small_caves(cave) do
    List.flatten(cave)
    |> Enum.uniq()
    |> Enum.filter(&(not Enum.member?(["start", "end"], &1) and String.downcase(&1) == &1))
  end
end

raw = File.read!("input.txt")
cave = Cave.parse_raw(raw)
paths = Cave.find_paths(cave, "start", [])
IO.puts(length(paths))

paths =
  List.foldl(
    Cave.get_small_caves(cave),
    [],
    fn allowed_twice, paths ->
      paths ++ Cave.find_paths(cave, "start", [], allowed_twice)
    end
  )

count = length(Enum.uniq(paths))
IO.puts(count)
