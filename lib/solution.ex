defmodule Solution do
  @moduledoc """
  A Macro-based approach to working with ok/error tuples
  """

  @doc """
  Matches when `x` is one of the following:

  - `:ok`
  - `{:ok, _}`
  - `{:ok, _, _}`
  -  or a longer tuple where the first element is the atom `:ok`

  iex> is_ok(:ok)
  true
  iex> is_ok({:ok, 42})
  true
  iex> is_ok({:ok, "I", "have", "many", "elements"})
  true
  iex> is_ok(:asdf)
  false
  iex> is_ok({:error, "failure"})
  false
  """
  defguard is_ok(x) when x == :ok or (is_tuple(x) and tuple_size(x) > 1 and elem(x, 0) == :ok)

  @doc """
  Matches when `x` is a long-enough ok-tuple that has more than `n_elems` elements.
  """
  defguard is_ok(x, n_elems) when is_ok(x) and (n_elems == 0 or tuple_size(x) >= n_elems)

  @doc """
  Matches when `x` is one of the following:

  - `:error`
  - `:undefined`
  - `{:error, _}`
  - `{:error, _, _}`
  -  or a longer tuple where the first element is the atom `:error`

  iex> is_error(:error)
  true
  iex> is_error({:error, 42})
  true
  iex> is_error({:error, "I", "have", "many", "elements"})
  true
  iex> is_error(:asdf)
  false
  iex> is_error({:ok, "success!"})
  iex> is_error(:undefined)
  true
  """
  defguard is_error(x) when x == :error or (is_tuple(x) and tuple_size(x) > 1 and elem(x, 0) == :error) or x == :undefined

  @doc """
  Matches when `x` is a long-enough ok-tuple that has more than `n_elems` elements.
  """
  defguard is_error(x, n_elems) when is_error(x) and (n_elems == 0 or tuple_size(x) >= n_elems)

  @doc """
  Matches when either `is_ok(x)` or `is_error(x)` matches.

  iex> is_okerror({:ok, "Yay!"})
  true
  iex> is_okerror({:error, "Nay"})
  true
  iex> is_okerror(false)
  false
  iex> is_okerror(:undefined)
  true
  iex> is_okerror({})
  false
  iex> is_okerror({:ok, "the", "quick", "brown", "fox"})
  true
  """
  defguard is_okerror(x) when is_ok(x) or is_error(x)

  @doc """
  Matches when `x` is a long-enough ok-tuple that has more than `n_elems` elements.

  Warning: Will _not_ match plain `:ok`, `:error` or `:undefined`!
  """

  defguard is_okerror(x, n_elems) when (elem(x, 0) == :error or elem(x, 0) == :ok) and tuple_size(x) >= n_elems

  @doc """
  Matches any ok datatype.
  (See also `is_ok`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro ok() do
    guard_env = Map.put(__ENV__, :context, :guard)
      {:when, [],
       [
         {:latest_solution_match____, [], nil},
         {:is_ok, [context: Elixir, import: Solution],
          [{:latest_solution_match____, [], nil}]}
       ]}
       |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  # Expands to x when is_ok(x, min_length)
  # Used internally by `expand_match`

  defmacro __ok__(0) do
    quote do
      ok()
    end
  end
  defmacro __ok__(min_length) do
    guard_env = Map.put(__ENV__, :context, :guard)
    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_ok, [context: Elixir, import: Solution],
        [{:latest_solution_match____, [], nil}, min_length]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end


  @doc """
  Matches `{:ok, res}`.
  `res` is then bound.
  (See also `is_ok`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro ok(res) do
    quote do
      {:ok, unquote(res)}
    end
  end

  @doc """
  Matches any error datatype.
  (See also `is_error`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro error() do
    guard_env = Map.put(__ENV__, :context, :guard)
    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_error, [context: Elixir, import: Solution],
        [{:latest_solution_match____, [], nil}]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  # Expands to x when is_error(x, min_length)
  # Used internally by `expand_match`
  defmacro __error__(0) do
    quote do
      error()
    end
  end
  defmacro __error__(min_length) do
    guard_env = Map.put(__ENV__, :context, :guard)
    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_error, [context: Elixir, import: Solution],
        [{:latest_solution_match____, [], nil}, min_length]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  @doc """
  Matches `{:error, res}`.
  `res` is then bound.
  (See also `is_error`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro error(res) do
    quote do
      {:error, unquote(res)}
    end
  end

  @doc """
  Matches any ok/error datatype.

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro okerror() do
    guard_env = Map.put(__ENV__, :context, :guard)
    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_okerror, [context: Elixir, import: Solution],
        [{:latest_solution_match____, [], nil}]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  defmacro okerror(res) do
    quote do
      {tag, unquote(res)} when tag == :ok or tag == :error
    end
  end

  # Expands to x when is_okerror(x, min_length)
  # Used internally by `expand_match`
  defmacro __okerror__(0) do
    quote do
      okerror()
    end
  end
  defmacro __okerror__(min_length) do
    guard_env = Map.put(__ENV__, :context, :guard)
    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_okerror, [context: Elixir, import: Solution],
        [{:latest_solution_match____, [], nil}, min_length]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end



  @doc """
  Works like a normal `case`-statement,
  but will expand macros to the left side of `->`.
  """
  defmacro scase(input, conditions) do
    guard_env = Map.put(__ENV__, :context, :guard)

    res =
      {:case, [], [input, conditions]}
      |> Macro.prewalk(fn node ->
        case node do
          {:->, meta, [[lhs], rhs]} ->
            # IO.inspect "Yay, we encountered: #{inspect {meta, lhs, rhs}}"
            {lhs, rhs_list} = expand_match(lhs, [rhs])
            rhs = {:__block__, [], rhs_list}
            node = {:->, meta, [[lhs], rhs]}
            a = Macro.expand(node, guard_env)
            # IO.inspect(Macro.to_string(a), label: "RESULTING NODE")

            a
          _ ->
            Macro.expand(node, guard_env)
        end
      end)

    # IO.puts(Macro.to_string(res))

    res
  end

  defp expand_match(lhs = {tag, meta, args}, rhs) when tag in [:ok, :error, :okerror] and is_list(args) do
    var = Macro.var(:latest_solution_match____, nil)
    args_amount =
      case Enum.count(args) do
        0 ->
          0
        other ->
          other + 1
      end
    elem_offset =
      case tag do
        :okerror -> 0
        _ -> 1
      end
    prefixes =
      args
      |> Enum.with_index
      |> Enum.map(fn {arg, index} ->
      full_index = index + elem_offset
        quote do
          unquote(arg) = elem(unquote(var), unquote(full_index))
        end
      end)

      lhs = {:"__#{tag}__", meta, [args_amount + elem_offset - 1]}

      {lhs, prefixes ++ rhs}
  end

  defp expand_match(other, rhs) do
    {other, rhs}
  end


  @doc """
  Works like a normal `with`-statement,
  but will expand macros to the left side of `<-`.
  """
  defmacro swith(statements, conditions)
  defmacro swith(statement, conditions) do
    do_swith([statement], conditions)
  end

  # Since `swith` is a normal macro bound to normal function rules,
  # define it for all possible arities.
  for arg_num <- (1..252) do
    args = (0..arg_num) |> Enum.map(fn num -> Macro.var(:"statement#{num}",  __MODULE__) end)
    @doc false
    defmacro swith(unquote_splicing(args), conditions) do
      do_swith(unquote(args), conditions)
    end
  end

  defp do_swith(statements, conditions) do
    guard_env = Map.put(__ENV__, :context, :guard)

    IO.inspect(statements, label: :statements)
    IO.inspect(conditions, label: :conditions)

    statements =
      statements
      |> Enum.flat_map(fn node ->
        case node do
            {:<-, meta, [lhs, rhs]} ->
            IO.inspect("Wooh! We encountered: #{inspect {meta, lhs, rhs}}")
            {lhs, extra_statements} =
              expand_match(lhs, [])
            lhs = Macro.expand(lhs, guard_env)
            node = {:<-, meta, [lhs, rhs]}

            IO.inspect(Macro.to_string(node), label: "RESULTING NODE")

            [node | extra_statements]
          _ ->
            [Macro.expand(node, guard_env)]
        end
      end)

    res =
      quote do
        with(unquote_splicing(statements), unquote(conditions))
      end

    IO.puts(Macro.to_string(res))

    res
  end
end


