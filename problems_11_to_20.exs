Code.require_file("problems_1_to_10.exs", __DIR__)

defmodule Single do
  @enforce_keys [:ch]
  defstruct [:ch]
end

defmodule Multiple do
  @enforce_keys [:ch, :count]
  defstruct [:ch, :count]
end

defmodule Problems11To20 do
  import Single
  import Multiple
  import Problems1To10

  @spec multiple(String.t, integer) :: %Multiple{ch: String.t, count: integer}
  def multiple(ch, count), do:  %Multiple{ch: to_string(ch), count: count}

  @spec single(String.t) :: %Single{ch: String.t}
  def single(ch), do: %Single{ch: to_string(ch)}

  def encode_modified(str) do
    str
    |> Problems1To10.encode
    |> Enum.map(fn(el) ->
      case el do
        {1, ch} ->
          single(ch)
        {count, ch} ->
          multiple(ch, count)
      end
    end)
  end

  def decode_modified(encoded_arr) do
    encoded_arr
    |> Enum.reduce([], fn (el, acc) ->
       [do_decode(el) | acc]
      end)
    |> myReverse
    |> to_string
  end

  defp do_decode(%Single{ch: c}), do: to_string(c)

  defp do_decode(%Multiple{ch: char, count: c}) do
   1..c |> Enum.reduce([], fn _x, acc -> [char | acc ] end) |> to_string
  end

  def encode_direct(str) do
    str
    |> String.split("", trim: true)
    |> Enum.reduce(%{val: nil, count: 0, result: []}, fn (el, %{val: v, count: c, result: r}=acc) ->
      acc = cond do
        v == nil ->
          %{acc | val: el}
        v == el ->
          %{acc | count: c + 1 }
        true ->
          %{ count: 0, result: [do_encode_direct(v, c) | r], val: el }
      end
      acc
    end)
    |> do_encode_direct
  end
  defp do_encode_direct(%{result: r, val: v, count: c}=map) when is_map(map) do
    [do_encode_direct(v, c) | r] |> myReverse
  end
  defp do_encode_direct(str, count) do
    case count do
      0 ->
       single(str)
      _ ->
        multiple(str, count + 1)
    end
  end

  def dupli(l) when is_list(l), do: do_dump(l, 2, 2)

  def repli(str, count) do
    str
    |> String.split("", trim: true)
    |> do_dump(count, count)
    |> to_string
  end

  defp do_dump([_h|t], 0, init_count), do: do_dump(t, init_count, init_count)
  defp do_dump([], _, _), do: []
  defp do_dump([h|_t]=l, count, init_count) do
    [h | do_dump(l, count - 1, init_count)]
  end

  def drop_every(str, count) do
    str
    |> String.split("", trim: true)
    |> do_drop_every([], 0, count)
    |> to_string()
  end
  defp do_drop_every(_l, [], start, _every_count) when start != 0, do: []
  defp do_drop_every(l, sliced, start, every_count) do
    str..stp = find_index_range(start, every_count)
    sliced ++ do_drop_every(l, Enum.slice(l, str..stp), stp + 2, every_count)
  end
  defp find_index_range(start, every_count) do
    stop = start + every_count - 2
    start..stop
  end

  def split(str, count) do
    l = str
    |> String.split("", trim: true)

    {to_string(Enum.drop(l, (length(l) - count) * -1)), to_string(Enum.drop(l, count))}
  end

  def slice(l, first, last) do
    l |> Enum.take(last) |> Enum.drop(first - 1) |> to_string
  end

  def rotate(l, count) when count < 0, do: rotate(l, length(l) + count)

  def rotate(l, count) do
    {right, left} = l
    |> to_string()
    |> split(count)
    merge(left, right) |> to_string()
  end

  defp merge(l, r), do: l <> r

  def remove_at(index, str) do
    l = str |> String.split("", trim: true)

    {l |> Enum.at(index-1) |> to_charlist(), l |> List.delete_at(index-1) |> to_string}
  end
end

case System.argv() do
  _ ->
    ExUnit.start()

    defmodule Problems11To20Test do
      use ExUnit.Case

      import Problems11To20

      test "Modified run-length encoding." do
        assert encode_modified("aaaabccaadeeee") == [multiple("a", 4), single("b"),multiple("c", 2), multiple("a", 2),single("d" ),multiple("e", 4)]
      end

      test "Decode a run-length encoded list." do
        assert decode_modified([multiple("a", 4), single("b"),multiple("c", 2), multiple("a", 2),single("d" ),multiple("e", 4)]) == "aaaabccaadeeee"
      end

      test "Run-length encoding of a list (direct solution)." do
        assert encode_direct("aaaabccaadeeee") == [multiple("a", 4), single("b"),multiple("c", 2), multiple("a", 2),single("d" ),multiple("e", 4)]
      end

      test "Duplicate the elements of a list." do
        assert dupli([1, 2, 3]) == [1,1,2,2,3,3]
      end

      test "Replicate the elements of a list a given number of times." do
        assert repli("abc", 3) == "aaabbbccc"
      end

      test "Drop every N'th element from a list." do
        assert drop_every("abcdefghik", 3) == "abdeghk"
      end

      test "Split a list into two parts; the length of the first part is given." do
        assert split("abcdefghik", 3) == {"abc", "defghik"}
      end

      test "Extract a slice from a list." do
        assert slice(['a','b','c','d','e','f','g','h','i','k'], 3, 7) == "cdefg"
      end

      test "Rotate a list N places to the left." do
        assert rotate(['a','b','c','d','e','f','g','h'], 3) == "defghabc"

        assert rotate(['a','b','c','d','e','f','g','h'], -2) == "ghabcdef"
      end

      test "Remove the K'th element from a list." do
        assert remove_at(2, "abcd") == {'b', "acd"}
      end
    end
end
