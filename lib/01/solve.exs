all_depths =
  File.stream!("input.txt")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&String.to_integer/1)
  |> Enum.to_list()

[previous_depth | depths] = all_depths

{solution, _} =
  List.foldl(
    depths,
    {0, previous_depth},
    fn depth, {count, previous_depth} ->
      {count + if(depth > previous_depth, do: 1, else: 0), depth}
    end
  )

IO.puts(solution)

[prev_depth_a, prev_depth_b, prev_depth_c | depths] = all_depths

{solution | _} =
  List.foldl(
    depths,
    {0, prev_depth_a, prev_depth_b, prev_depth_c},
    fn depth, {count, prev_depth_a, prev_depth_b, prev_depth_c} ->
      {
        count +
          if(prev_depth_b + prev_depth_c + depth > prev_depth_a + prev_depth_b + prev_depth_c,
            do: 1,
            else: 0
          ),
        prev_depth_b,
        prev_depth_c,
        depth
      }
    end
  )

IO.puts(solution)
