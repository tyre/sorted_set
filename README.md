# SortedSet
A sorted set library for Elixir. Implements the
[Set](http://elixir-lang.org/docs/v1.0/elixir/Set.html) protocol.

## Installation

Add the following to `deps` section of your `mix.exs`:
  `{:sorted_set, "~> 0.2"}`

and then `mix deps.get`. That's it!

Generate the documentations with `mix docs`.

## About

Sorted sets are backed by a [red-black tree](http://en.wikipedia.org/wiki/Red%E2%80%93black_tree), providing lookup in O(log(n)).
