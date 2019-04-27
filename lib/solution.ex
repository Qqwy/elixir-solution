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
  """
  defguard is_ok(x) when x == :ok or (is_tuple(x) and elem(x, 0) == :ok)
  defguard is_ok(x, n_elems) when elem(x, 0) == :ok and tuple_size(x) >= n_elems

  @doc """
  Matches when `x` is one of the following:

  - `:error`
  - `:undefined`
  - `{:error, _}`
  - `{:error, _, _}`
  -  or a longer tuple where the first element is the atom `:error`
  """
  defguard is_error(x) when x == :error or (is_tuple(x) and elem(x, 0) == :error) or x == :undefined
  defguard is_error(x, n_elems) when elem(x, 0) == :error and tuple_size(x) >= n_elems

  @doc """
  Matches when either `is_ok(x)` or `is_error(x)` matches.
  """
  defguard is_okerror(x) when is_ok(x) or is_error(x)
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
  # Used internally by `expand_case_match`
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
  # Used internally by `expand_case_match`
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
            IO.inspect "Yay, we encountered: #{inspect {meta, lhs, rhs}}"
            {lhs, rhs} = expand_case_match(lhs, rhs)
            node = {:->, meta, [[lhs], rhs]}
            a = Macro.expand(node, guard_env)
            IO.inspect(Macro.to_string(a), label: "RESULTING NODE")

            a
          _ ->
            Macro.expand(node, guard_env)
        end
      end)

    IO.puts(Macro.to_string(res))

    res
  end

  defp expand_case_match(lhs = {tag, meta, args}, rhs) when tag in [:ok, :error] do
    var = Macro.var(:latest_solution_match____, nil)
    rhs =
      args
      |> Enum.with_index
      |> Enum.map(fn {arg, index} ->
        quote do
          unquote(arg) = elem(unquote(var), unquote(index) + 1)
        end
      end)
      |> Enum.reduce(rhs, fn prefix, rhs ->
          quote do
            unquote(prefix)
            unquote(rhs)
          end
        end)

      lhs = {:"__#{tag}__", meta, [Enum.count(args) + 1]}

      {lhs, rhs}
  end

  defp expand_case_match(other, rhs) do
    {other, rhs}
  end

  @doc """
  Works like a normal `with`-statement,
  but will expand macros to the left side of `<-`.
  """
  defmacro swith(statements, conditions) do
    res =
    {:with, [], [statements, conditions]}
    |> Macro.prewalk(&Macro.expand(&1, __ENV__))

    IO.puts(Macro.to_string(res))

    res
  end
end


