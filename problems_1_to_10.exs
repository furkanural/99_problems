defmodule Problems1To10 do

  def myLast([head | []]), do: head

  def myLast([ _head | tail ]) do
    myLast(tail)
  end

  def myButLast( [] ), do: raise "Empty List"
  def myButLast( [_head | []]), do: raise "Too few elements"
  def myButLast([head | tail]) do
    case length(tail) do
      1 ->
        head
      _ ->
        myButLast(tail)
    end
  end

  def elementAt([head | _tail], 1), do: head

  def elementAt([_head|tail], count) do
    elementAt(tail, count - 1)
  end

  def myLength(list), do: myLength(list, 0)

  defp myLength([], count), do: count
  defp myLength([_head|tail], count) do
    myLength(tail, count + 1)
  end

  def myReverse([]), do: []
  def myReverse([head|tail]), do: myReverse(tail) ++ [head]

  def isPalindrome(list), do: list == myReverse(list)

  def flatten([]), do: []
  def flatten([head | tail]) when is_list(head), do: flatten(head) ++ flatten(tail)
  def flatten([head | tail]), do: [ head | flatten(tail)]

  def compress(list) do
    Enum.reduce( list, %{:el => nil, :list => []}, fn(el, acc) ->
      case acc.el == el do
        true ->
          acc
        false ->
          %{ :el => el, :list => [el | acc.list] }
      end
    end) |>  Map.get(:list, []) |> myReverse
  end

  def pack([head|tail]), do: do_pack(tail, head, [], [])

  defp do_pack([], prev_element, simple_pack, pack) do
    merge_for_pack(prev_element, simple_pack, pack) |> myReverse
  end
  defp do_pack([head|tail], prev_element, simple_pack, pack) when head == prev_element do
    do_pack(tail, head, [head|simple_pack], pack)
  end
  defp do_pack([head|tail], prev_element, simple_pack, pack) when head != prev_element do
    do_pack(tail, head, [], merge_for_pack(prev_element, simple_pack, pack))
  end
  defp merge_for_pack(el, group, list), do:  [to_string([el|group])|list]

  def encode(string) do
    string
    |> String.split("", trim: true)
    |> pack
    |> Enum.reduce([], fn(el, acc) ->
     [ { String.length(el), el |> String.first() |> String.to_charlist() } | acc]
    end)
    |> myReverse
  end
end

case System.argv() do
  _ ->
    ExUnit.start()

    defmodule Problems1To10Test do
      use ExUnit.Case

      import Problems1To10

      test "Find the last element of a list." do
        assert myLast([1,2,3,4]) == 4

        assert myLast(['x','y','z']) == 'z'
      end


      test "Find the last but one element of a list." do
        assert myButLast([1,2,3,4]) == 3

        assert myButLast(Enum.to_list(?a..?z)) == ?y
      end

      test "Find the K'th element of a list. The first element in the list is number 1." do
        assert elementAt([1,2,3], 2) == 2

        assert elementAt('haskell', 5) == ?e
      end

      test "Find the number of elements of a list." do
        assert myLength([123, 456, 789]) == 3

        assert myLength('Hello, world!') == 13
      end

      test "Reverse a list." do
        assert myReverse('A man, a plan, a canal, panama!') == '!amanap ,lanac a ,nalp a ,nam A'

        assert myReverse([1,2,3,4]) == [4,3,2,1]
      end

      test "Find out whether a list is a palindrome. A palindrome can be read forward or backward; e.g. (x a m a x)." do
        assert isPalindrome([1,2,3]) == false

        assert isPalindrome('madamimadam') == true

        assert isPalindrome([1,2,4,8,16,8,4,2,1]) == true
      end

      test "Flatten a nested list structure." do
        assert flatten([5]) == [5]

        assert flatten([1, [2, [3, 4], 5]]) == [1,2,3,4,5]

        assert flatten([]) == []
      end

      test "Eliminate consecutive duplicates of list elements." do
        assert compress('aaaabccaadeeee') == 'abcade'
      end

      test "Pack consecutive duplicates of list elements into sublists. If a list contains repeated elements they should be placed in separate sublists." do
        assert pack(['a', 'a', 'a', 'a', 'b', 'c', 'c', 'a', 'a', 'd', 'e', 'e', 'e', 'e']) == ["aaaa","b","cc","aa","d","eeee"]
      end

      test "Run-length encoding of a list" do
        assert encode("aaaabccaadeeee") == [{4,'a'}, {1,'b'}, {2,'c'}, {2,'a'}, {1,'d'}, {4,'e'}]
      end
    end
end
