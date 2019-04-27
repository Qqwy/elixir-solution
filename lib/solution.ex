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

  @doc """
  Matches when `x` is one of the following:

  - `:error`
  - `:undefined`
  - `{:error, _}`
  - `{:error, _, _}`
  -  or a longer tuple where the first element is the atom `:error`
  """
  defguard is_error(x) when x == :error or (is_tuple(x) and elem(x, 0) == :error) or x == :undefined

  @doc """
  Matches when either `is_ok(x)` or `is_error(x)` matches.
  """
  defguard is_okerror(x) when is_ok(x) or is_error(x)

  @doc """
  Matches any ok datatype.
  (See also `is_ok`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro ok() do
    guard_env = Map.put(__ENV__, :context, :guard)
      {:when, [],
       [
         {:x, [], Elixir},
         {:is_ok, [context: Elixir, import: Solution],
          [{:x, [], Elixir}]}
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
       {:x, [], Elixir},
       {:is_error, [context: Elixir, import: Solution],
        [{:x, [], Elixir}]}
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
       {:x, [], Elixir},
       {:is_okerror, [context: Elixir, import: Solution],
        [{:x, [], Elixir}]}
     ]}
     |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  @doc """
  Works like a normal `case`-statement,
  but will expand macros to the left side of `->`.
  """
  defmacro scase(input, conditions) do
    res =
    {:case, [], [input, conditions]}
    |> Macro.prewalk(&Macro.expand(&1, __ENV__))

    IO.puts(Macro.to_string(res))

    res
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


