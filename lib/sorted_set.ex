defmodule SortedSet do
  @moduledoc """

  """

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

  ## SortedSet predicate methods

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

  # If set1 is larger than set2, it cannot be a subset of it
  def subset?(%SortedSet{size: size1}, %SortedSet{size: size2}) when size1 > size2 do
    false
  end

  def subset?(%SortedSet{}=set1, %SortedSet{}=set2) do
    Enum.all?(to_list(set1), fn(set1_member) ->
      member? set2, set1_member
    end)
  end

  def disjoint?(%SortedSet{size: size1}=set1, %SortedSet{size: size2}=set2) when size1 <= size2 do
    not Enum.any?(to_list(set1), fn(set1_member) ->
      member?(set2, set1_member)
    end)
  end

  def disjoint?(%SortedSet{}=set1, %SortedSet{}=set2) do
    disjoint?(set2, set1)
  end

  ## SortedSet Operations

  def union(%SortedSet{size: size1}=set1, %SortedSet{size: size2}=set2) when size1 <= size2  do
    Enum.reduce(to_list(set1), set2, fn(member, new_set) ->
      put(new_set, member)
    end)
  end

  def union(%SortedSet{}=set1, %SortedSet{}=set2) do
    union(set2, set1)
  end

  # If either set is empty, the intersection is the empty set
  def intersection(%SortedSet{size: 0}=empty_set, _) do
    empty_set
  end

  # If either set is empty, the intersection is the empty set
  def intersection(_, %SortedSet{size: 0}=empty_set) do
    empty_set
  end

  def intersection(%SortedSet{size: size1}=set1, %SortedSet{size: size2}=set2) when size1 <= size2 do
    Enum.reduce(to_list(set1), SortedSet.new, fn(set1_member, new_set) ->
      if SortedSet.member?(set2, set1_member) do
        SortedSet.put(new_set, set1_member)
      else
        new_set
      end
    end)
  end

  def intersection(%SortedSet{}=set1, %SortedSet{}=set2) do
    intersection(set2, set1)
  end

  # When the first set is empty, the difference is the empty set
  def difference(%SortedSet{size: 0}=empty_set, _) do
    empty_set
  end

  # When the other set is empty, the difference is the first set
  def difference(%SortedSet{}=set1, %SortedSet{size: 0}) do
    set1
  end

  def difference(%SortedSet{}=set1, %SortedSet{}=set2) do
    Enum.reduce(to_list(set1), set1, fn(set1_member, new_set) ->
      if SortedSet.member?(set2, set1_member) do
        delete(new_set, set1_member)
      else
        new_set
      end
    end)
  end

  ## Private helper functions

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

defimpl Enumerable, for: SortedSet do
  def count(%SortedSet{size: size}), do: {:ok, size}
  def member?(%SortedSet{}=set, element), do: {:ok, SortedSet.member?(set, element)}
  def reduce(%SortedSet{}=set, acc, fun) do
    SortedSet.to_list(set)
    |> Enumerable.List.reduce(acc, fun)
  end
end

defimpl Collectable, for: SortedSet do
  def into(original) do
    {original, fn
      set, {:cont, new_member} -> SortedSet.put(set, new_member)
      set, :done -> set
      _, :halt -> :ok
    end}
  end
end

# We want our own inspect so that it will hide the underlying :members and :size
# fields. Otherwise users may try to play with them directly.
defimpl Inspect, for: SortedSet do
  import Inspect.Algebra

  def inspect(set, opts) do
    concat ["#SortedSet<", Inspect.List.inspect(SortedSet.to_list(set), opts), ">"]
  end
end

