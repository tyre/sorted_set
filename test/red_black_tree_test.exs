defmodule RedBlackTreeTest do
  use ExUnit.Case, async: true
  alias RedBlackTree.Node

  test "initializing a red black tree" do
    assert %RedBlackTree{} == RedBlackTree.new
    assert 0 == RedBlackTree.new.size

    assert [{1,1}, {2,2}, {:c,:c}] == RedBlackTree.to_list RedBlackTree.new([1,2,:c])
    assert [{1,1}, {2,2}, {:c,:c}] == RedBlackTree.to_list RedBlackTree.new([1,2,:c])
  end

  test "to_list" do
    empty_tree = RedBlackTree.new
    bigger_tree = RedBlackTree.new([d: 1, b: 2, c: 3, a: 4])
    assert [] == RedBlackTree.to_list empty_tree

    # It should return the elements in order
    assert [{:a, 4}, {:b, 2}, {:c, 3}, {:d, 1}] == RedBlackTree.to_list bigger_tree
    assert 4 == bigger_tree.size
  end

  test "insert" do
    red_black_tree = RedBlackTree.insert RedBlackTree.new, 1, :bubbles
    assert [{1, :bubbles}] == RedBlackTree.to_list red_black_tree
    assert 1 == red_black_tree.size

    red_black_tree = RedBlackTree.insert red_black_tree, 0, :walrus
    assert [{0, :walrus}, {1, :bubbles}] == RedBlackTree.to_list red_black_tree
    assert 2 == red_black_tree.size
  end

  test "delete" do
    initial_tree = RedBlackTree.new([d: 1, b: 2, c: 3, a: 4])
    pruned_tree = RedBlackTree.delete(initial_tree, :c)

    assert 3 == pruned_tree.size
    assert [{:a, 4}, {:b, 2}, {:d, 1}] == RedBlackTree.to_list pruned_tree

    assert 2 == RedBlackTree.delete(pruned_tree, :a).size
    assert [{:b, 2}, {:d, 1}] == RedBlackTree.to_list RedBlackTree.delete(pruned_tree, :a)

    assert [] == RedBlackTree.to_list RedBlackTree.delete RedBlackTree.new, :b
  end

  test "has_key?" do
    assert RedBlackTree.has_key?(RedBlackTree.new([a: 1, b: 2]), :b)
    assert not RedBlackTree.has_key?(RedBlackTree.new([a: 1, b: 2]), :c)
  end

  #
  #              B (Black)
  #             /         \
  #            A          D (Red)
  #                      /       \
  #                     C         F (Red)
  #                              /       \
  #                             E         G
  #
  test "balancing a right-heavy red tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :b,
        color: :black,
        left: %Node{key: :a},
        right: %Node{
          key: :d,
          color: :red,
          left: %Node{key: :c},
          right: %Node{
            key: :f,
            color: :red,
            left: %Node{key: :e},
            right: %Node{key: :g}
          }
        }
      }
    }
    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #
  #         B (Black)
  #        /         \
  #       A       F (Red)
  #              /       \
  #           D (Red)     G
  #          /       \
  #         C         E
  #
  test "balancing a center-right-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :b,
        color: :black,
        left: %Node{key: :a},
        right: %Node{
          key: :f,
          color: :red,
          left: %Node{
            key: :d,
            color: :red,
            left: %Node{key: :c},
            right: %Node{key: :e}
          },
          right: %Node{key: :g}
        }
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #                 F (Black)
  #                /         \
  #               D (Red)     G
  #              /       \
  #           B (Red)     E
  #          /       \
  #         A          C
  #
  #
  test "balancing a left-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :f,
        color: :black,
        left: %Node{
          key: :d,
          color: :red,
          left: %Node{
            key: :b,
            color: :red,
            left: %Node{key: :a},
            right: %Node{key: :c}
          },
          right: %Node{key: :e}
        },
        right: %Node{key: :g}
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #
  #               F (Black)
  #              /         \
  #          B (Red)        G
  #         /       \
  #        A         D (Red)
  #                 /       \
  #                C         E
  #
  test "balancing a center-left-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :f,
        color: :black,
        left: %Node{
          key: :b,
          color: :red,
          left: %Node{key: :a},
          right: %Node{
            key: :d,
            color: :red,
            left: %Node{key: :c},
            right: %Node{key: :e}
          },
        },
        right: %Node{key: :g}
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #
  #            D (Red)
  #           /       \
  #     B (Black)      F (Black)
  #    /         \    /         \
  #   A           C  E           G
  #
  defp balanced_tree do
    %RedBlackTree{
      size: 5,
      root: %Node{
        key: :d,
        color: :red,
        left: %Node{
          key: :b,
          color: :black,
          left: %Node{ key: :a },
          right: %Node{ key: :c }
        },
        right: %Node{
          key: :f,
          color: :black,
          left: %Node{ key: :e },
          right: %Node{ key: :g }
        }
      }
    }
  end
end
