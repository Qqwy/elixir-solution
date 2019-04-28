defmodule Solution.Enum do
  require Solution
  import Solution

  @doc """
  Changes a list of oks into `{:ok, list_of_values}`

  If any element of the list is an error, returns this error element.

  If all elements are oks, takes the first non-tag value from each of them for the list.
  (in the case of `:ok`, nothing is added to the resulting list.)

      iex> combine([{:ok, 1}, {:ok, "a", %{meta: "this will be dropped"}}, {:ok, :asdf}])
      {:ok, [1, "a", :asdf]}
      iex> combine([{:ok, 1}, {:ok, 2}, {:error, 3}])
      {:error, 3}
      iex> combine([{:ok, 1}, {:ok, 2}, {:error, 3, 4, 5}])
      {:error, 3, 4, 5}
  """
  def combine(enum) do
    result =
      Enum.reduce_while(enum, [], fn
        x, acc when is_ok(x, 2) ->
          {:cont, [elem(x, 1) | acc]}
        x, acc when is_ok(x, 0) or is_ok(x, 1) ->
          {:cont, acc}
        x, _acc when is_error(x) ->
          {:halt, x}
      end)

    case result do
      x when is_error(x) -> x
      x -> {:ok, :lists.reverse(x)}
    end
  end

  @doc """
  Returns a list of only all `ok`-type elements in the enumerable.

      iex> oks([{:ok, 1}, {:error, 2}, {:ok, 3}])
      [{:ok, 1}, {:ok, 3}]
  """
  def oks(enum) do
    enum
    |> Enum.filter(&is_ok/1)
  end

  @doc """
  Returns a list of the values of all `ok`-type elements in the enumerable.

  Note that the 'value' is taken to be the first element:

      iex> ok_vals([{:ok, 1}, {:ok, 2,3,4,5}])
      [1, 2]
  """
  def ok_vals(enum) do
    enum
    |> Enum.filter(&is_ok(&1, 2))
    |> Enum.map(fn oktuple ->
      elem(oktuple, 1)
    end)
  end

  @doc """
  Returns a list of the tuple-values of all `ok`-type elements in the enumerable.

  The 'tuple-value' consists of all elements in the `ok`-type element,
  except for the initial `:ok` tag.

      iex> ok_valstuples([{:ok, 1}, {:ok, 2,3,4,5}])
      [{1}, {2,3,4,5}]
  """
  def ok_valstuples(enum) do
    enum
    |> Enum.filter(&is_ok(&1, 2))
    |> Enum.map(fn oktuple ->
      oktuple
      |> Tuple.delete_at(0)
    end)
  end

  @doc """
  Returns a list of only all `error`-type elements in the enumerable.

      iex> errors([{:ok, 1}, {:error, 2}, {:ok, 3}])
      [{:error, 2}]
  """
  def errors(enum) do
    enum
    |> Enum.filter(&is_error/1)
  end

  @doc """
  Returns a list of the values of all `error`-type elements in the enumerable.

  Note that the 'value' is taken to be the first element:

      iex> error_vals([{:error, 1}, {:error, 2,3,4,5}])
      [1, 2]
  """
  def error_vals(enum) do
    enum
    |> Enum.filter(&is_error(&1, 2))
    |> Enum.map(fn errortuple ->
      elem(errortuple, 1)
    end)
  end

  @doc """
  Returns a list of the tuple-values of all `error`-type elements in the enumerable.

  The 'tuple-value' consists of all elements in the `error`-type element,
  except for the initial `:error` tag.

      iex> error_valstuples([{:error, 1}, {:error, 2,3,4,5}])
      [{1}, {2,3,4,5}]
  """
  def error_valstuples(enum) do
    enum
    |> Enum.filter(&is_error(&1, 2))
    |> Enum.map(fn errortuple ->
      errortuple
      |> Tuple.delete_at(0)
    end)
  end
end
