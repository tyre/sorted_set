# SortedSet
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
# [2, 6, 10]
```
