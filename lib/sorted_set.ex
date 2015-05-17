defmodule SortedSet do

# delete(set, value)  Deletes value from set
# difference(set1, set2)  Returns a set that is set1 without the members of set2
# disjoint?(set1, set2) Checks if set1 and set2 have no members in common
# equal?(set1, set2)  Check if two sets are equal using ===
# intersection(set1, set2)  Returns a set containing only members in common between set1 and set2
# member?(set, value) Checks if set contains value
# put(set, value) Inserts value into set if it does not already contain it
# size(set) Returns the number of elements in set
# subset?(set1, set2) Checks if set1‘s members are all contained in set2
# to_list(set)  Converts set to a list
# union(set1, set2)  Returns a set containing all members of set1 and set2

  @behaviour Set

  # Define the type as opaque

  @opaque t :: %__MODULE__{members: list, size: non_neg_integer}
  @doc false
  defstruct size: 0, members: []


  def new do
    %SortedSet{members: [], size: 0}
  end

  def new(members) do
    Enum.reduce(members, SortedSet.new, fn(member, set) ->
      put(set, member)
    end)
  end

  def size(%SortedSet{size: size}) do
    size
  end

  def to_list(%SortedSet{members: members}) do
    members
  end

  def put(%SortedSet{members: members, size: size}, element) do
    {new_members, members_added} = do_put(members, element)
    %SortedSet{members: new_members, size: size + members_added}
  end

  def delete(%SortedSet{members: members, size: size}, element) do
    {new_members, members_removed} = do_delete(members, element)
    %SortedSet{members: new_members, size: size - members_removed}
  end

  def union(%SortedSet{size: size1}=set1, %SortedSet{size: size2}=set2) when size1 > size2 do
    union(set2, set1)
  end

  def union(%SortedSet{}=set1, %SortedSet{}=set2) do
    Enum.reduce(to_list(set1), set2, fn(member, new_set) ->
      put(new_set, member)
    end)
  end

  def member?(%SortedSet{}=set, element) do
    do_member?(to_list(set), element)
  end

  # If the sizes are not equal, no need to check members
  def equal?(%SortedSet{size: size1}, %SortedSet{size: size2}) when size1 != size2 do
    false
  end

  def equal?(%SortedSet{}=set1, %SortedSet{}=set2) do
    Enum.reduce(to_list(set1), set2, fn(member, new_set) ->
      put(new_set, member)
    end)
  end

  # SortedSet put

  defp do_put([head|tail], element) when element > head do
    {tail_members, members_added} = do_put(tail, element)
    {[head | tail_members], members_added}
  end

  defp do_put([head|_tail]=sorted_set, element) when element < head do
    {[element | sorted_set], 1}
  end

  defp do_put([head|_tail]=sorted_set, element) when element == head do
    {sorted_set, 0}
  end

  defp do_put([], element), do: {[element], 1}

  # SortedSet delete

  # If the element is less than the one we are looking at, we can safely
  # know it was never in the set
  defp do_delete([head|_tail]=members, element) when element < head do
    {members, 0}
  end

  # If the element is greater than the current head, we haven't reached where it
  # might exist in the set. Recur again on the tail.
  defp do_delete([head|tail], element) when element > head do
    {tail_members, members_removed} = do_delete(tail, element)
    {[head | tail_members], members_removed}
  end

  # If the element matches the head, drop it
  defp do_delete([head|tail], element) when element == head do
    {tail, 1}
  end

  defp do_delete([], _element) do
    {[], 0}
  end

  # SortedSet member?

  defp do_member?([head|_tail], element) when element < head  do
    false
  end

  defp do_member?([head|tail], element) when element > head  do
    do_member?(tail, element)
  end

  defp do_member?([head|_tail], element) when element == head  do
    true
  end

  defp do_member?([], _element), do: false
end

