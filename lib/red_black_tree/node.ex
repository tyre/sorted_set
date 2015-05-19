defmodule RedBlackTree.Node do
  defstruct(
    color: :black,
    key: nil,
    value: nil,
    left: nil,
    right: nil
  )

  def new(key, value) do
    %__MODULE__{key: key, value: value}
  end
end
