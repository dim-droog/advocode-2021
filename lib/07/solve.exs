defmodule Crabs do
  def fuel1(crabpos, pos) do
    abs(pos - crabpos)
  end

  def fuel2(crabpos, pos) do
    with n = abs(pos - crabpos) do
      div(n * n + n, 2)
    end
  end

  def cumulative_fuel(pos, crabs, fuelfn) do
    Enum.sum(for crabpos <- crabs, do: fuelfn.(crabpos, pos))
  end

  def solve(crabs, fuelfn) do
    with {lbound, ubound} = Enum.min_max(crabs) do
      Enum.min(for pos <- lbound..ubound, do: cumulative_fuel(pos, crabs, fuelfn))
    end
  end
end

{_, raw} = File.read("input.txt")
crabs = String.split(String.trim(raw), ",") |> Enum.map(&String.to_integer(&1))
IO.puts(Crabs.solve(crabs, &Crabs.fuel1/2))
IO.puts(Crabs.solve(crabs, &Crabs.fuel2/2))
