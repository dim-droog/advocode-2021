defmodule Packet do
  use Bitwise

  def parse_raw(raw) do
    with num_bits = 4 * String.length(raw) do
      <<String.to_integer(raw, 16)::size(num_bits)>>
    end
  end

  def get_bits({bits, cursor}, n) do
    with <<v::size(n), rest::bitstring>> = bits do
      {v, {rest, cursor + n}}
    end
  end

  def read_value(bitcursor, value \\ 0)

  def read_value({<<0::1, d::4, rest::bitstring>>, cursor}, value) do
    {value <<< 4 ||| d, {rest, cursor + 5}}
  end

  def read_value({<<1::1, d::4, rest::bitstring>>, cursor}, value) do
    read_value({rest, cursor + 5}, value <<< 4 ||| d)
  end

  def exec_op(opcode, values) do
    case opcode do
      0 -> Enum.sum(values)
      1 -> Enum.product(values)
      2 -> Enum.min(values)
      3 -> Enum.max(values)
      5 -> if(Enum.at(values, 0) > Enum.at(values, 1), do: 1, else: 0)
      6 -> if(Enum.at(values, 0) < Enum.at(values, 1), do: 1, else: 0)
      7 -> if(Enum.at(values, 0) == Enum.at(values, 1), do: 1, else: 0)
    end
  end

  def op_run_length(run_length, opcode, bitcursor, values \\ [])

  def op_run_length(0, opcode, {bits, cursor}, values) do
    {exec_op(opcode, values), {bits, cursor}}
  end

  def op_run_length(run_length, opcode, {bits, cursor}, values) do
    with {v, {bits, new_cursor}} = process_packet({bits, cursor}) do
      op_run_length(run_length - (new_cursor - cursor), opcode, {bits, new_cursor}, values ++ [v])
    end
  end

  def op_packet_count(count, opcode, bitcursor, values \\ [])

  def op_packet_count(0, opcode, {bits, cursor}, values) do
    {exec_op(opcode, values), {bits, cursor}}
  end

  def op_packet_count(count, opcode, {bits, cursor}, values) do
    with {v, {bits, cursor}} = process_packet({bits, cursor}) do
      op_packet_count(count - 1, opcode, {bits, cursor}, values ++ [v])
    end
  end

  def operator(ptype, {<<ltype::1, rest::bitstring>>, cursor}) do
    if(ltype == 0,
      do:
        with <<run_length::15, rest::bitstring>> = rest do
          op_run_length(run_length, ptype, {rest, cursor + 16})
        end,
      else:
        with <<count::11, rest::bitstring>> = rest do
          op_packet_count(count, ptype, {rest, cursor + 12})
        end
    )
  end

  def add_version(version) do
    :ets.insert(
      :versions,
      {"version_sum", :ets.lookup_element(:versions, "version_sum", 2) + version}
    )
  end

  def process_packet(bitcursor) do
    with {version, bitcursor} = get_bits(bitcursor, 3),
         {ptype, bitcursor} = get_bits(bitcursor, 3) do
      add_version(version)
      if(ptype == 4, do: read_value(bitcursor), else: operator(ptype, bitcursor))
    end
  end

  def process_raw(raw) do
    :ets.new(:versions, [:named_table])
    :ets.insert(:versions, {"version_sum", 0})
    bits = Packet.parse_raw(raw)
    {v, _} = Packet.process_packet({bits, 0})
    version_sum = :ets.lookup_element(:versions, "version_sum", 2)
    :ets.delete(:versions)
    {v, version_sum}
  end
end

raw = String.trim(File.read!("input.txt"))
{result, version_sum} = Packet.process_raw(raw)
IO.puts(version_sum)
IO.puts(result)
