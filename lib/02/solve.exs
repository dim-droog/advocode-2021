commands =
  File.stream!("input.txt")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(fn s -> String.split(s, " ") end)
  |> Stream.map(fn [d, sv] -> {d, String.to_integer(sv)} end)
  |> Enum.to_list()

{position, depth} =
  List.foldl(
    commands,
    {0, 0},
    fn
      {"forward", v}, {pos, dpt} -> {pos + v, dpt}
      {"up", v}, {pos, dpt} -> {pos, dpt - v}
      {"down", v}, {pos, dpt} -> {pos, dpt + v}
    end
  )

IO.puts(position * depth)

{position, depth, aim} =
  List.foldl(
    commands,
    {0, 0, 0},
    fn
      {"forward", v}, {pos, dpt, aim} -> {pos + v, dpt + v * aim, aim}
      {"up", v}, {pos, dpt, aim} -> {pos, dpt, aim - v}
      {"down", v}, {pos, dpt, aim} -> {pos, dpt, aim + v}
    end
  )

IO.puts(position * depth)
