defmodule Util do
  def get_frequency_map(chars, strings) do
    for c <- chars,
        into: %{},
        do: {c, Enum.count(Enum.filter(strings, &Enum.member?(String.graphemes(&1), c)))}
  end
end

defmodule Segment do
  @segments_to_digit %{
    "abcefg" => 0,
    "cf" => 1,
    "acdeg" => 2,
    "acdfg" => 3,
    "bcdf" => 4,
    "abdfg" => 5,
    "abdefg" => 6,
    "acf" => 7,
    "abcdefg" => 8,
    "abcdfg" => 9
  }

  # Segments with unique lengths: digits 1, 4, 7, 8
  @specialsegments ["cf", "bcdf", "acf", "abcdefg"]

  @chars ["a", "b", "c", "d", "e", "f", "g"]

  @char_to_frequency Util.get_frequency_map(@chars, Map.keys(@segments_to_digit))
  def char_to_frequency, do: @char_to_frequency

  @char_to_frequency_specialsegments Util.get_frequency_map(@chars, @specialsegments)
  def char_to_frequency_specialsegments, do: @char_to_frequency_specialsegments

  # Frequencies 6, 4, 9 (of "b", "e", "f") are unique in @char_to_frequency.
  # The other chars ("a", "c", "d", "g") can be decided on by looking at their
  # frequency in all segments, and then their frequency in @specialsegments:
  #
  #   "a" => 8 => 2
  #   "c" => 8 => 4
  #   "d" => 7 => 2
  #   "g" => 7 => 1
  #
  # Yielding unique 'frequency tuples' {{8, 2} => "a", {8, 4} => "c", ...}.

  @unique_frequency_to_char %{6 => "b", 4 => "e", 9 => "f"}

  @frequency_tuple_to_char %{{8, 2} => "a", {8, 4} => "c", {7, 2} => "d", {7, 1} => "g"}

  def infer_decoding_map(input_signals) do
    with input_frequencies = Util.get_frequency_map(@chars, input_signals),
         input_specialsegments =
           Enum.filter(input_signals, &Enum.member?([2, 3, 4, 7], String.length(&1))),
         frequency_in_specialsegments = Util.get_frequency_map(@chars, input_specialsegments),
         frequency_tuples =
           for(
             {c, f} <- input_frequencies,
             into: %{},
             do: {c, {f, frequency_in_specialsegments[c]}}
           ) do
      for(
        {char_in, {frq_1, frq_2}} <- frequency_tuples,
        into: %{},
        do:
          {char_in,
           if(Enum.member?(Map.keys(@unique_frequency_to_char), frq_1),
             do: @unique_frequency_to_char[frq_1],
             else: @frequency_tuple_to_char[{frq_1, frq_2}]
           )}
      )
    end
  end

  def todigit(s) do
    with ordered_segments = List.to_string(Enum.sort(String.to_charlist(s))) do
      @segments_to_digit[ordered_segments]
    end
  end

  def decode_signal(decoding_map, s) do
    for(i <- 0..(String.length(s) - 1), do: decoding_map[String.at(s, i)])
    |> List.to_string()
    |> todigit()
  end

  def decode_entry(input_signals, outputs) do
    with decoding_map = infer_decoding_map(input_signals),
         decoded_outputs = Enum.map(outputs, &decode_signal(decoding_map, &1)) do
      Enum.sum(for i <- 0..3, do: Enum.at(decoded_outputs, i) * Integer.pow(10, 3 - i))
    end
  end
end

entries =
  File.stream!("input.txt")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&Enum.split(List.flatten(Regex.scan(~r/\w+/, &1)), 10))
  |> Enum.to_list()

IO.puts(
  Enum.sum(
    Enum.map(
      entries,
      fn {_, outputs} ->
        Enum.count(outputs, &Enum.member?([2, 3, 4, 7], String.length(&1)))
      end
    )
  )
)

IO.puts(
  Enum.sum(
    Enum.map(entries, fn {input_signals, outputs} ->
      Segment.decode_entry(input_signals, outputs)
    end)
  )
)
