# SortedSet
[![Hex.pm](https://img.shields.io/hexpm/v/sorted_set.svg)](https://hex.pm/packages/sorted_set) [![Travis](https://img.shields.io/travis/SenecaSystems/sorted_set.svg)](https://travis-ci.org/SenecaSystems/sorted_set)


A sorted set library for Elixir. Implements the
[Set](http://elixir-lang.org/docs/v1.0/elixir/Set.html) protocol.

## Installation

Add the following to `deps` section of your `mix.exs`:
  `{:sorted_set, "~> 1.0"}`

and then `mix deps.get`. That's it!

Generate the documentation with `mix docs`.

## About

Sorted sets are backed by a [red-black tree](http://en.wikipedia.org/wiki/Red%E2%80%93black_tree), providing lookup in O(log(n)). Size is tracked automatically, resulting in O(1)
performance.


## Basic Usage

`SortedSet` implements the `Set` behaviour, `Enumerable`, and `Collectable`.

```elixir
SortedSet.new()
|> Set.put(5)
|> Set.put(1)
|> Set.put(3)
|> Enum.reduce([], fn (element, acc) -> [element*2|acc] end)
|> Enum.reverse
# => [2, 6, 10]
```

Can also take a custom `:comparator` function to determine ordering. The
function should accept two terms and

  - return `0` if they are considered equal
  - return `-1` if the first is considered less than or before the second
  - return `1` if the first is considered greater than or after the second

This function is passed on to the underlying [red-black tree implementation](https://github.com/SenecaSystems/red_black_tree) implemetation. Otherwise, the
default Erlang term comparison is used (with an extra bit to handle edgecases — see note in [RedBlackTree](https://github.com/SenecaSystems/red_black_tree)
README.)

```elixir
SortedSet.new([:a, :b, :c], comparator: fn (term1, term2) ->
   RedBlackTree.compare_terms(term1, term2) * -1
 end)
# => #SortedSet<[:c, :b, :a]>
```
