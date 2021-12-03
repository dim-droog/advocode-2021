defmodule Util do
  def getcolumn(vv, i) do
    for v <- vv, do: String.to_integer(String.at(v, i), 2)
  end

  def frequencies_for_column(vv, i) do
    with n <- length(vv) do
      Enum.sum(getcolumn(vv, i)) |> (&{n - &1, &1}).()
    end
  end
end

base2strings =
  File.stream!("input.txt")
  |> Stream.map(&String.trim_trailing/1)
  |> Enum.to_list()

frequencies = for i <- 0..11, do: Util.frequencies_for_column(base2strings, i)

[gamma, epsilon] =
  List.foldl(
    frequencies,
    ["", ""],
    fn {count_zro, count_one}, [gamma, epsilon] ->
      cond do
        count_zro > count_one -> [gamma <> "0", epsilon <> "1"]
        true -> [gamma <> "1", epsilon <> "0"]
      end
    end
  )
  |> Enum.map(&String.to_integer(&1, 2))

IO.puts(gamma * epsilon)

[oxygen, co2] =
  List.foldl(
    Enum.to_list(0..10),
    [base2strings, base2strings],
    fn i, [oxygen, co2] ->
      with {n_oxy, n_co2} <- {length(oxygen), length(co2)},
           {{oxy_zro, oxy_one}, {co2_zro, co2_one}} <-
             {Util.frequencies_for_column(oxygen, i), Util.frequencies_for_column(co2, i)},
           oxy_keep <- if(oxy_one >= oxy_zro, do: "1", else: "0"),
           co2_keep <- if(co2_zro <= co2_one, do: "0", else: "1") do
        [
          cond do
            n_oxy == 1 -> oxygen
            true -> Enum.filter(oxygen, &(String.at(&1, i) == oxy_keep))
          end,
          cond do
            n_co2 == 1 -> co2
            true -> Enum.filter(co2, &(String.at(&1, i) == co2_keep))
          end
        ]
      end
    end
  )
  |> Enum.map(fn [base2] -> String.to_integer(base2, 2) end)

IO.puts(oxygen * co2)
