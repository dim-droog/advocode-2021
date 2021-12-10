defmodule Syntax do
  @matching_close %{?( => ?), ?[ => ?], ?{ => ?}, ?< => ?>}
  @opening Map.keys(@matching_close)
  def opening, do: @opening

  @error_score %{?) => 3, ?] => 57, ?} => 1197, ?> => 25137}
  @completion_score %{?) => 1, ?] => 2, ?} => 3, ?> => 4}

  def push(stk, c), do: stk ++ [c]

  def pop([]), do: {nil, []}

  def pop(stk) do
    with {new_stk, [popped]} = Enum.split(stk, -1), do: {popped, new_stk}
  end

  def score(input, stk \\ [])
  def score([], _stk), do: 0

  def score([c | rest], stk) do
    if(
      Enum.member?(@opening, c),
      do: score(rest, push(stk, c)),
      else:
        with {popped, new_stk} = pop(stk) do
          if(c == @matching_close[popped], do: score(rest, new_stk), else: @error_score[c])
        end
    )
  end

  def complete(input, stk \\ [])

  def complete([], stk) do
    for opn <- Enum.reverse(stk), do: @matching_close[opn]
  end

  def complete([c | rest], stk) do
    if(
      Enum.member?(@opening, c),
      do: complete(rest, push(stk, c)),
      else:
        with {_, new_stk} = pop(stk) do
          complete(rest, new_stk)
        end
    )
  end

  def complete_score(input) do
    List.foldl(complete(input), 0, fn c, points -> 5 * points + @completion_score[c] end)
  end
end

lines = File.stream!("input.txt") |> Stream.map(&String.trim_trailing/1) |> Enum.to_list()

{error_total, noncorrupt} =
  List.foldl(
    lines,
    {0, []},
    fn line, {error_total, noncorrupt} ->
      with input = String.to_charlist(line),
           score = Syntax.score(input) do
        if(Syntax.score(input) == 0,
          do: {error_total, noncorrupt ++ [input]},
          else: {error_total + score, noncorrupt}
        )
      end
    end
  )

IO.puts(error_total)

completion_scores = Enum.map(noncorrupt, &Syntax.complete_score/1)
IO.puts(Enum.at(Enum.sort(completion_scores), div(length(completion_scores), 2)))
