defmodule SortedSetTest do
  use ExUnit.Case

  test "it creates an empty set with size 0" do
    assert 0 == SortedSet.size SortedSet.new
  end

  test "it sorts an existing list on creation" do
    assert [1,3,5] == SortedSet.to_list SortedSet.new [1,5,3]
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

  test "it can perform a union on two sorted sets" do
    set1 = %SortedSet{members: [1,2,3,4,5], size: 5}
    set2 = %SortedSet{members: [1,3,5,7,9], size: 5}
    union = SortedSet.union(set1, set2)
    assert [1,2,3,4,5,7,9] == SortedSet.to_list union
    assert 7 == SortedSet.size union
  end

  test "it can tell if a set contains an item" do
    assert SortedSet.member?(SortedSet.new([1,2,3]), 1)
    assert not SortedSet.member?(SortedSet.new([1,2,3]), 4)
    assert not SortedSet.member?(SortedSet.new([]), 4)
  end

  test "it can tell if two sets are equal" do
    assert SortedSet.equal?(SortedSet.new, SortedSet.new)
    assert SortedSet.equal?(SortedSet.new([1,2,3,4]), SortedSet.new([1,2,3,4]))

    # Ensure it isn't confused by subsets
    assert not SortedSet.equal?(SortedSet.new([1,2,3]), SortedSet.new([1,2]))
    # Or supersets
    assert not SortedSet.equal?(SortedSet.new([1,2]), SortedSet.new([1,2,3]))
  end

  test "it can tell if one set is the subset of another" do
    assert SortedSet.subset?(SortedSet.new, SortedSet.new)

    assert SortedSet.subset?(SortedSet.new([1,2,3]), SortedSet.new([1,2,3,4]))
    assert not SortedSet.subset?(SortedSet.new([1,2,3,4]), SortedSet.new([1,2,3]))
  end
end
