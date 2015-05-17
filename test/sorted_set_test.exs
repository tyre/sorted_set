defmodule SortedSetTest do
  use ExUnit.Case

  test "it creates an empty set with size 0" do
    assert 0 == SortedSet.size SortedSet.new
  end

  test "it can put an element into the set" do
    new_set = SortedSet.put SortedSet.new, 1
    assert [1] == SortedSet.to_list new_set
    assert 1 == SortedSet.size new_set
  end

  test "it puts elements in sorted order" do
    set = SortedSet.put(SortedSet.new(), 2)
    |> SortedSet.put(3)
    |> SortedSet.put(1)
    assert [1,2,3] == SortedSet.to_list(set)
    assert 3 == SortedSet.size set
  end

  test "it can delete from the set" do
    set = %SortedSet{members: [1,2,3,4,5], size: 5}
    new_set = SortedSet.delete(set, 3)
    assert [1,2,4,5] == SortedSet.to_list new_set
    assert 4 == SortedSet.size new_set

    assert [] == SortedSet.to_list SortedSet.delete(SortedSet.new(), 1)
  end
end
