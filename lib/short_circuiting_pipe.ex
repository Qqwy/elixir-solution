defmodule ShortCircuitingPipe do
  require Solution

  @doc """
  A pipeline-like operator wrapping `is_ok/1`,
  so it will short-circuit as soon as a value that is not one of:
  - `{:ok, val}`
  - `{:ok, val, meta}`
  - a tuple with more elements whose first element is `:ok`

  is passed.

      iex> require ShortCircuitingPipe
      iex> import ShortCircuitingPipe
      iex> {:ok, %{a: 42}} ~> Map.fetch(:a) ~> fn x -> {:ok, x * 2} end.()
      {:ok, 84}

      iex> require ShortCircuitingPipe
      iex> import ShortCircuitingPipe
      iex> {:error, :boom} ~> Map.fetch(:a) ~> fn x -> {:ok, x * 2} end.()
      {:error, :boom}

      iex> require ShortCircuitingPipe
      iex> import ShortCircuitingPipe
      iex> {:ok, %{a: 42}} ~> Map.fetch(:unexistent) ~> fn x -> {:ok, x * 2} end.()
      :error

  Note that only `val` (the element at index `1` in the tuple)
  will be passed on to the next stage of the pipeline:


      iex> require ShortCircuitingPipe
      iex> import ShortCircuitingPipe
      iex> {:ok, "I", "have", "many", "elements"} ~> fn(x) -> [x, x] end.()
      ["I", "I"]

  Also note that just passing `:ok` will not be matched in this case,
  since there is no `value` to pass on to the next stage of the pipeline.

      iex> require ShortCircuitingPipe
      iex> import ShortCircuitingPipe
      iex> :ok ~> fn (x) -> [x, x] end.()
      :ok

  """
  defmacro lhs ~> {call, line, args} do
    # Prepend a variable that will be called 'value' to the list of arguments,
    # to be used in the happy path.
    value = quote do: value
    prepended_args = [value | args || []]

    quote do
      Solution.scase unquote(lhs) do
        ok(value) -> unquote({call, line, prepended_args})
        other -> other
      end
    end
  end
end
