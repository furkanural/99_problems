Code.require_file("problems_1_to_10.exs", __DIR__)

defmodule Problems21To28 do
  import Problems1To10

  def insert_at(el, str, position) do
    l = str |> String.split("", trim: true)

    l
    |> Enum.take(position - 1)
    |> to_string()
    |> Kernel.<>(to_string([ to_string(el) | l |> Enum.drop(length(l) - position - 1) ]))
  end

  def range(first, last) when first == last, do: [ first ]
  def range(first, last), do: [ first | range(first + 1, last)]

  def rnd_select(l, count) when is_list(l), do: do_rnd_select(l, count)
  def rnd_select(str, count) do
    str
    |> String.split("", trim: true)
    |> do_rnd_select(count)
    |> to_string()
  end
  defp do_rnd_select(_, 0), do: []
  defp do_rnd_select(l, c) do
    i = rnd_index(l)

    [ Enum.at(l, i) | do_rnd_select(List.delete_at(l, i), c-1) ]
  end
  defp rnd_index(l) when length(l) < 2, do: 0
  defp rnd_index(l), do: l |> length() |> Kernel.-(1) |> :rand.uniform()

  def diff_select(count, end_of_range) do
    1..end_of_range
    |> Enum.to_list()
    |> rnd_select(count)
  end

  def rnd_permu(str) do
    rnd_select(str, String.length(str))
  end

  def combinations(n, term) when is_bitstring(term), do: combinations(n, String.split(term, "", trim: true))
  def combinations(1, term) do
    Enum.map(term, fn x -> [x] end)
  end
  def combinations(n, list) do
    Enum.filter(tails(list), fn x -> length(x) >= n end)
    |> Enum.reduce([], fn [head|tail], acc ->
      rs = Enum.reduce(combinations(n-1, tail), [], fn x, acc ->
        [[head | x] | acc]
      end)
      rs ++ acc
    end) |> myReverse
  end

  defp tails([]), do: []
  defp tails([_h|t]=list), do: [list|tails(t)]

  def group([], _), do: [{}]

  def group([n|ns], l) do
    Enum.reduce(combinations(n, l), [], fn x, acc ->
      Enum.reduce(group(ns, remnant(x, l)), [], fn y, ac ->
        [ Tuple.append(y, x) | ac ]
      end) |> Enum.concat(acc)
    end)
  end
  defp remnant(x, l) when is_list(x) and is_list(l), do: l -- x

  def lsort(l), do: l |> qsort

  defp qsort([]), do: []
  defp qsort([pivot|[]]), do: [pivot]
  defp qsort( [pivot | tail] ) do
    lower = Enum.filter(tail, fn n -> String.length(n) < String.length(pivot) end)
    higher = Enum.filter(tail, fn n -> String.length(n) >= String.length(pivot) end)

    Enum.concat(qsort(lower), [pivot | qsort(higher)])
  end
end

case System.argv() do
  _ ->
    ExUnit.start()

    defmodule Problems21To28Test do
      use ExUnit.Case

      import Problems21To28

      test "Insert an element at a given position into a list." do
        assert insert_at('X', "abcd", 2) == "aXbcd"
      end

      test "Create a list containing all integers within a given range." do
        assert range(4, 9) == [4,5,6,7,8,9]
      end

      test "Extract a given number of randomly selected elements from a list." do
        assert String.length(rnd_select("abcdefgh", 3)) == 3
      end

      test "Lotto: Draw N different random numbers from the set 1..M." do
        assert length(diff_select(6, 49)) == 6
      end

      test "Generate a random permutation of the elements of a list." do
        assert String.length(rnd_permu("abcdef")) == String.length("abcdef")
      end

      test "(**) Generate the combinations of K distinct objects chosen from the N elements of a list" do
        assert combinations(3, "abcdef") == [
          ["a", "b", "c"], ["a", "b", "d"], ["a", "b", "e"], ["a", "b", "f"],
          ["a", "c", "d"], ["a", "c", "e"], ["a", "c", "f"],
          ["a", "d", "e"], ["a", "d", "f"],
          ["a", "e", "f"],
          ["b", "c", "d"], ["b", "c", "e"], ["b", "c", "f"],
          ["b", "d", "e"], ["b", "d", "f"],
          ["b", "e", "f"],
          ["c", "d", "e"], ["c", "d", "f"],
          ["c", "e", "f"],
          ["d", "e", "f"]
        ]
        assert length(combinations(5, ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"])) == 792
      end

      test "Group the elements of a set into disjoint subsets." do
        rs = Enum.uniq(group([2,3,4], ["aldo","beat","carla","david","evi","flip","gary","hugo","ida"]))

        assert length(rs) == 1260

        rs = group([2,2,5], ["aldo","beat","carla","david","evi","flip","gary","hugo","ida"])

        assert length(rs) == 756
      end

      test "Sorting a list of lists according to length of sublists" do
        assert lsort(["abc","de","fgh","de","ijkl","mn","o"]) == ["o","de","de","mn","abc","fgh","ijkl"]
      end
    end
end
