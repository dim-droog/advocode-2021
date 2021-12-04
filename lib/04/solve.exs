defmodule Bingo do
  def flat_board(all_cells, board_idx) do
    Enum.slice(all_cells, 25 * board_idx, 25)
  end

  def getcol(all_cells, board_idx, col) do
    with base = 25 * board_idx + col,
         indices = for(i <- 0..4, do: base + i * 5) do
      Enum.map(indices, fn i -> Enum.at(all_cells, i) end)
    end
  end

  def getrow(all_cells, board_idx, row) do
    Enum.slice(all_cells, 25 * board_idx + 5 * row, 5)
  end

  def check_col(all_cells, board_idx, col, nums) do
    with cells = getcol(all_cells, board_idx, col) do
      length(cells -- cells -- nums) == 5
    end
  end

  def check_row(all_cells, board_idx, row, nums) do
    with cells = getrow(all_cells, board_idx, row) do
      length(cells -- cells -- nums) == 5
    end
  end

  def score(all_cells, board_idx, nums) do
    with full_cols =
           Enum.sum(
             for i <- 0..4, do: if(check_col(all_cells, board_idx, i, nums), do: 1, else: 0)
           ),
         full_rows =
           Enum.sum(
             for i <- 0..4, do: if(check_row(all_cells, board_idx, i, nums), do: 1, else: 0)
           ) do
      if full_cols + full_rows > 0,
        do: Enum.sum(flat_board(all_cells, board_idx) -- nums) * Enum.at(nums, -1),
        else: 0
    end
  end

  def first_winning(_all_cells, _numbers, [winning_score], _len) do
    winning_score
  end

  def first_winning(all_cells, numbers, winning_scores, len) do
    with nums = Enum.slice(numbers, 0, len),
         scores = for(i <- 0..99, do: score(all_cells, i, nums)),
         new_winning = Enum.filter(scores, &(&1 > 0)) do
      first_winning(all_cells, numbers, winning_scores ++ new_winning, len + 1)
    end
  end

  def last_winning(all_cells, numbers, boards, len) do
    with nums = Enum.slice(numbers, 0, len),
         wins =
           Enum.filter(for(i <- boards, do: {i, score(all_cells, i, nums)}), fn {_, score} ->
             score > 0
           end),
         winning_boards = Enum.map(wins, fn {i, _} -> i end),
         winning_scores = Enum.map(wins, fn {_, score} -> score end) do
      if length(boards) - length(wins) == 0,
        do: Enum.at(winning_scores, 0),
        else: last_winning(all_cells, numbers, boards -- winning_boards, len + 1)
    end
  end
end

{_, raw} = File.read("input.txt")

numbers = Regex.scan(~r/(\d{1,2})[,\n]/, raw) |> Enum.map(fn [_, s] -> String.to_integer(s) end)

all_cells =
  Regex.scan(~r/((?:\d{1,2} +){4}\d{1,2})\n/, raw)
  |> Enum.map(fn [_, s] -> Regex.scan(~r/\d{1,2}/, s) end)
  |> Enum.map(fn ll -> Enum.map(ll, fn [s] -> String.to_integer(s) end) end)
  |> List.flatten()

sol1 = Bingo.first_winning(all_cells, numbers, [], 5)
IO.puts(sol1)

sol2 = Bingo.last_winning(all_cells, numbers, Enum.to_list(0..99), 5)
IO.puts(sol2)
