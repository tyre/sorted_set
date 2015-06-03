defmodule RedBlackTree do
  alias RedBlackTree.Node

  defstruct root: nil, size: 0

  def new() do
    %RedBlackTree{}
  end

  def new(values) when is_list(values) do
    new(%RedBlackTree{}, values)
  end

  defp new(tree, []) do
    tree
  end

  # Allow initialization with key/value tuples
  defp new(tree, [{key, value}|tail]) do
    new(RedBlackTree.insert(tree, key, value), tail)
  end

  # Allow initialization with individual values, in which case they will be both
  # the key and the value
  defp new(tree, [key|tail]) do
    new(RedBlackTree.insert(tree, key, key), tail)
  end

  def insert(%RedBlackTree{root: nil}, key, value) do
    %RedBlackTree{root: Node.new(key, value), size: 1}
  end

  def insert(%RedBlackTree{root: root, size: size}=tree, key, value) do
    {nodes_added, new_root} = do_insert(root, key, value, 1)
    %RedBlackTree{
      tree |
      root: make_node_black(new_root),
      size: size + nodes_added
    }
  end

  def delete(%RedBlackTree{root: root, size: size}=tree, key) do
    {nodes_removed, new_root} = do_delete(root, key)
    %RedBlackTree{
      tree |
      root: new_root,
      size: size - nodes_removed
    }
  end

  def has_key?(%RedBlackTree{root: root}, key) do
    do_has_key?(root, key)
  end

  defp do_has_key?(nil, _key) do
    false
  end

  defp do_has_key?(%Node{key: node_key}, search_key) when node_key == search_key do
    true
  end

  defp do_has_key?(%Node{key: node_key, left: left}, search_key) when search_key < node_key do
    do_has_key?(left, search_key)
  end

  defp do_has_key?(%Node{key: node_key, right: right}, search_key) when search_key > node_key do
    do_has_key?(right, search_key)
  end

  def balance(%RedBlackTree{root: root}=tree) do
    %RedBlackTree{tree | root: do_balance(root)}
  end

  def to_list(%RedBlackTree{}=tree) do
    reduce(tree, [], fn (node, members) ->
      [{node.key, node.value} | members]
    end) |> Enum.reverse
  end

  @doc """
  For each node, calls the provided function passing in (node, acc)
  Optionally takes an order as the first argument which can be one of
  `:in_order`, `:pre_order`, or `:post_order`.

  Defaults to `:in_order` if no order is given.
  """
  def reduce(tree, acc, fun) do
    reduce(:in_order, tree, acc, fun)
  end

  def reduce(_order, %RedBlackTree{root: nil}, acc, _fun) do
    acc
  end

  def reduce(order, %RedBlackTree{root: root}, acc, fun) do
    do_reduce(order, root, acc, fun)
  end

  ## Helpers

  defp make_node_black(%Node{}=node) do
    %Node{node | color: :black}
  end

  ### Operations

  #### Insert

  defp do_insert(nil, insert_key, insert_value, depth) do
    {
      1,
      %Node{
        Node.new(insert_key, insert_value, depth) |
        color: :red
      }
    }

  end

  defp do_insert(%Node{key: node_key}=node, insert_key, insert_value, _depth) when node_key == insert_key do
    {0, %Node{node | value: insert_value}}
  end

  defp do_insert(%Node{key: node_key, left: left}=node, insert_key, insert_value, depth) when insert_key < node_key do
    {nodes_added, new_left} = do_insert(left, insert_key, insert_value, depth + 1)
    {nodes_added, %Node{node | left: do_balance(new_left)}}
  end

  defp do_insert(%Node{key: node_key, right: right}=node, insert_key, insert_value, depth) when insert_key > node_key do
    {nodes_added, new_right} = do_insert(right, insert_key, insert_value, depth + 1)
    {nodes_added, %Node{node | right: do_balance(new_right)}}
  end

  #### Delete

  # If we reach a leaf and the key never matched, do nothing
  defp do_delete(nil, _key) do
    {0, nil}
  end

  # If both the right and left are nil, the new tree is nil. For example,
  # deleting A in the following tree results in B having no left
  #
  #        B
  #       / \
  #      A   C
  #
  defp do_delete(%Node{key: node_key, left: nil, right: nil}, delete_key) when node_key == delete_key do
    {1, nil}
  end

  # If left is nil and there is a right, promote the right. For example,
  # deleting C in the following tree results in B's right becoming D
  #
  #        B
  #       / \
  #      A   C
  #           \
  #            D
  #
  defp do_delete(%Node{key: node_key, left: nil, right: right}, delete_key) when node_key == delete_key do
    {1, right}
  end

  # If left is nil and there is a right, promote the right. For example,
  # deleting B in the following tree results in C's left becoming D
  #
  #        C
  #       / \
  #      B   D
  #     /
  #    A
  #
  defp do_delete(%Node{key: node_key, left: left, right: nil}, delete_key) when node_key == delete_key do
    {1, left}
  end

  # If there are both left and right nodes, recursively promote the left-most
  # nodes. For example, deleting E below results in the following:
  #
  #        G      =>         G
  #       / \               / \
  #      E   H    =>       C   H
  #     / \               / \
  #    C   F      =>     B   D
  #   / \               /     \
  #  A   D        =>   A       F
  #   \
  #    B
  #
  #
  defp do_delete(%Node{key: node_key, left: left, right: right}, delete_key) when node_key == delete_key do
    {
      1,
      do_balance(%Node{
        left |
        left: do_balance(promote(left)),
        right: right
      })
    }
  end

  defp do_delete(%Node{key: node_key, left: left}=node, delete_key) when delete_key < node_key do
    {nodes_removed, new_left} = do_delete(left, delete_key)
    {
      nodes_removed,
      %Node{
        node |
        left: do_balance(new_left)
      }
    }
  end

  defp do_delete(%Node{key: node_key, right: right}=node, delete_key) when delete_key > node_key do
    {nodes_removed, new_right} = do_delete(right, delete_key)
    {
      nodes_removed,
      %Node{
        node |
        right: do_balance(new_right)
      }
    }
  end

  defp promote(nil) do
    nil
  end

  defp promote(%Node{left: left, right: nil}) do
    %Node{ left | color: :red }
  end

  defp promote(%Node{left: nil, right: right}) do
    %Node{ right | color: :red }
  end

  defp promote(%Node{left: left, right: right}) do
    balance(%Node{
      left |
      left: do_balance(promote(left)),
      right: right
    })
  end

  #### Balance

  # If we have a tree that looks like this:
  #              B (Black)
  #             /         \
  #            A          D (Red)
  #                      /       \
  #                     C         F (Red)
  #                              /       \
  #                             E         G
  #
  #
  # Rotate to balance and look like this:
  #
  #                   D (Red)
  #                 /         \
  #          B (Black)        F (Black)
  #         /        \       /         \
  #        A          C     E           G
  #
  #
  defp do_balance(
    %Node{
      color: :black,
      left: a_node,
      right: %Node{
        color: :red,
        left: c_node,
        right: %Node{
          color: :red,
          left: e_node,
          right: g_node
        }=f_node
      }=d_node
    }=b_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end

  # If we have a tree that looks like this:
  #
  #         B (Black)
  #        /         \
  #       A       F (Red)
  #              /       \
  #           D (Red)     G
  #          /       \
  #         C         E
  #
  # Rotate to balance like so:
  #
  #                D (Red)
  #               /       \
  #        B (Black)       F (Black)
  #       /         \     /         \
  #      A           C   E           G
  #
  #
  #
  defp do_balance(
    %Node{
      color: :black,
      left: a_node,
      right: %Node{
        color: :red,
        left: %Node{
          color: :red,
          left: c_node,
          right: e_node
        }=d_node,
        right: g_node
      }=f_node
    }=b_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end

  # If we have a tree that looks like this:
  #
  #
  #                 F (Black)
  #                /         \
  #               D (Red)     G
  #              /       \
  #           B (Red)     E
  #          /       \
  #         A          C
  #
  #
  # Rebalance to look like so:
  #
  #               D (Red)
  #              /       \
  #      B (Black)        F (Black)
  #     /         \      /         \
  #    A           C    E           G
  #
  defp do_balance(%Node{
      color: :black,
      left: %Node{
        color: :red,
        left: %Node{
          color: :red,
          left: a_node,
          right: c_node
        }=b_node,
        right: e_node
      }=d_node,
      right: g_node
    }=f_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end

  # If we have a tree that looks like this:
  #
  #               F (Black)
  #              /         \
  #          B (Red)        G
  #         /       \
  #        A         D (Red)
  #                 /       \
  #                C         E
  #
  # Rebalance to look like this:
  #
  #            D (Red)
  #           /       \
  #     B (Black)      F (Black)
  #    /         \    /         \
  #   A           C  E           G
  #
  defp do_balance(%Node{
      color: :black,
      left: %Node{
        color: :red,
        left: a_node,
        right: %Node{
          color: :red,
          left: c_node,
          right: e_node
        }=d_node
      }=b_node,
      right: g_node
    }=f_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end


  defp do_balance(node) do
    node
  end

  defp balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node) do
    min_depth = min_depth([a_node, b_node, c_node, d_node, e_node, f_node, g_node])
    %Node {
      d_node |
      color: :red,
      depth: min_depth,
      left: %Node{b_node | color: :black, depth: min_depth + 1,
        left: %Node{a_node | depth: min_depth + 2},
        right: %Node{c_node | depth: min_depth + 2}},
      right: %Node{f_node | color: :black, depth: min_depth + 1,
        left: %Node{e_node | depth: min_depth + 2},
        right: %Node{g_node | depth: min_depth + 2},}
    }
  end

  defp min_depth(list_of_nodes) do
    Enum.reduce(list_of_nodes, -1, fn (node, acc) ->
      if acc == -1 || node.depth < acc do
        node.depth
      else
        acc
      end
    end)
  end

  defp do_reduce(_order, nil, acc, _fun) do
    acc
  end

  # self, left, right
  defp do_reduce(:pre_order, %Node{left: left, right: right}=node, acc, fun) do
    acc_after_self = fun.(node, acc)
    acc_after_left = do_reduce(:pre_order, left, acc_after_self, fun)
    do_reduce(:pre_order, right, acc_after_left, fun)
  end

  # left, self, right
  defp do_reduce(:in_order, %Node{left: left, right: right}=node, acc, fun) do
    acc_after_left = do_reduce(:in_order, left, acc, fun)
    acc_after_self = fun.(node, acc_after_left)
    do_reduce(:in_order, right, acc_after_self, fun)
  end

  # left, right, self
  defp do_reduce(:post_order, %Node{left: left, right: right}=node, acc, fun) do
    acc_after_left = do_reduce(:post_order, left, acc, fun)
    acc_after_right = do_reduce(:post_order, right, acc_after_left, fun)
    fun.(node, acc_after_right)
  end
end
