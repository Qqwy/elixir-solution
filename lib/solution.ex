defmodule Solution do
  @moduledoc """
  A Macro-based approach to working with ok/error tuples

  This module exposes two main things:

  1. guard-clause macros `is_ok/1`, `is_error/1` and `is_okerror/1` (as well as arity-2 variants of the same), to be used whenever you like.
  2. `scase/2` and `swith/2`, replacements for `case` and `with`-statements respectively that allow you to pattern match on ok/error tuples more effectively, as well as bind to one ore multiple of the values stored inside.

  """

  @doc """
  Matches when `x` is one of the following:

  - `:ok`
  - `{:ok, _}`
  - `{:ok, _, _}`
  -  or a longer tuple where the first element is the atom `:ok` (`{:ok, ...}`)

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
  defguard is_ok(x) when x == :ok or (is_tuple(x) and tuple_size(x) >= 1 and elem(x, 0) == :ok)

  @doc """
  Matches when `x` is a long-enough ok-tuple that has more than `n_elems` elements.
  """
  defguard is_ok(x, n_elems) when is_ok(x) and (n_elems == 0 or tuple_size(x) >= n_elems)

  @doc """
  Matches when `x` is one of the following:

  - `:error`
  - `{:error, _}`
  - `{:error, _, _}`
  -  or a longer tuple where the first element is the atom `:error`. (`{:error, ...}`)

      iex> is_error(:error)
      true
      iex> is_error({:error, 42})
      true
      iex> is_error({:error, "I", "have", "many", "elements"})
      true
      iex> is_error(:asdf)
      false
      iex> is_error({:ok, "success!"})
      false
  """
  defguard is_error(x)
           when x == :error or (is_tuple(x) and tuple_size(x) >= 1 and elem(x, 0) == :error)

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
      iex> is_okerror({})
      false
      iex> is_okerror({:ok, "the", "quick", "brown", "fox"})
      true
  """
  defguard is_okerror(x) when is_ok(x) or is_error(x)

  @doc """
  Matches when `x` is a long-enough ok-tuple that has more than `n_elems` elements.

  Warning: Will _not_ match plain `:ok` or `:error`!
  """

  defguard is_okerror(x, n_elems) when is_ok(x, n_elems) or is_error(x, n_elems)

  @doc """
  Matches any ok datatype.

  (See also `is_ok/1`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro ok() do
    guard_env = Map.put(__ENV__, :context, :guard)

    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_ok, [context: Elixir, import: Solution], [{:latest_solution_match____, [], nil}]}
     ]}
    |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  # Expands to x when is_ok(x, min_length)
  # Used internally by `expand_match`
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
  Matches `{:ok, res}` (as well as tuples with more elements). `res` is then bound.

  (See also `is_ok/1`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro ok(res) do
    quote do
      {:ok, unquote(res)}
    end
  end

  @doc """
  Matches any error datatype.

  (See also `is_error/1`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro error() do
    guard_env = Map.put(__ENV__, :context, :guard)

    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_error, [context: Elixir, import: Solution], [{:latest_solution_match____, [], nil}]}
     ]}
    |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  @doc """
  Matches `{:error, res}` (as well as tuples with more elements). `res` is then bound.

  (See also `is_error/1`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro error(res) do
    quote do
      {:error, unquote(res)}
    end
  end

  # Expands to x when is_error(x, min_length)
  # Used internally by `expand_match`
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
  Matches any ok/error datatype.

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro okerror() do
    guard_env = Map.put(__ENV__, :context, :guard)

    {:when, [],
     [
       {:latest_solution_match____, [], nil},
       {:is_okerror, [context: Elixir, import: Solution], [{:latest_solution_match____, [], nil}]}
     ]}
    |> Macro.prewalk(&Macro.expand(&1, guard_env))
  end

  @doc """
  Matches any ok or error type. `tag` is then bound to `:ok` or `:error`.

  (See also `is_okerror/1`)

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro okerror(tag) do
    quote do
      {unquote(tag), _} when unquote(tag) in [:ok, :error]
    end
  end

  @doc """
  Matches `{:ok, res}`, `{:error, res}` (as well as tuples with more elements). `tag` and `res` are bound.

  (See also `is_okerror/1`)

  `tag` is bound to the value `:ok` or `:error` depending on the tuple.
  `res` is bound to what the second element might be.

  Has to be used inside the LHS of a `scase` or `swith` statement.
  """
  defmacro okerror(tag, res) do
    quote do
      {unquote(tag), unquote(res)} when unquote(tag) in [:ok, :error]
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
  but will expand `ok()`, `error()` and `okerror()`macros to the left side of `->`.

      iex> scase {:ok, 10} do
      ...>  ok() -> "Yay!"
      ...>  _ -> "Failure"
      ...>  end
      "Yay!"


  You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
  to be used inside the case expression:

      iex> scase {:ok, "foo", 42} do
      ...>   ok(res, extra) ->
      ...>     "result: \#{res}, extra: \#{extra}"
      ...>  _ ->
      ...>    "Failure"
      ...> end
      "result: foo, extra: 42"

  Note that for `ok()` and `error()`, the first argument will match the first element after the `:ok` or `:error` tag.
  On the other hand, for `okerror()`, the first argument will match the tag `:ok` or `:error`.

  Note: It is not required to import Solution to use the macros inside `swith` without prefixing them.
  """
  defmacro scase(input, conditions) do
    guard_env = Map.put(__ENV__, :context, :guard)

    {:case, [], [input, conditions]}
    |> Macro.prewalk(fn node ->
      case node do
        {:->, meta, [[lhs], rhs]} ->
          {lhs, rhs_list} = expand_match(lhs, [rhs])
          lhs = Macro.expand(lhs, guard_env)
          rhs = {:__block__, [], rhs_list}
          node = {:->, meta, [[lhs], rhs]}
          Macro.expand(node, guard_env)

        other ->
          Macro.expand(other, __CALLER__)
      end
    end)
  end

  defp expand_match({tag, meta, args}, rhs)
       when tag in [:ok, :error, :okerror] and is_list(args) do
    var = Macro.var(:latest_solution_match____, nil)
    args_amount = args_amount(args)

    prefixes =
      args
      |> Enum.with_index()
      |> Enum.map(fn {arg, index} ->
        full_index = index + elem_offset(tag)

        quote do
          unquote(arg) = elem(unquote(var), unquote(full_index))
        end
      end)

    lhs = {:"__#{tag}__", meta, [max(args_amount + elem_offset(tag) - 1, 0)]}

    {lhs, prefixes ++ rhs}
  end

  defp expand_match(other, rhs) do
    {other, rhs}
  end

  defp args_amount(args) do
    case Enum.count(args) do
      0 ->
        0

      other ->
        other + 1
    end
  end

  defp elem_offset(:okerror), do: 0
  defp elem_offset(_), do: 1

  @doc """
  Works like a normal `with`-statement,
  but will expand `ok()`, `error()` and `okerror()` macros to the left side of `<-`.


      iex> x = {:ok, 10}
      iex> y = {:ok, 33}
      iex> swith ok(res) <- x,
      ...>       ok(res2) <- y do
      ...>      "We have: \#{res} \#{res2}"
      ...>    else
      ...>      _ -> "Failure"
      ...>  end
      "We have: 10 33"


  You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
  to be used inside the rest of the `swith`-expression:

      iex> x = {:ok, 10}
      iex> y = {:error, 33}
      iex> z = {:ok, %{a: 42}}
      iex> swith ok(res) <- x,
      ...>       error(res2) <- y,
      ...>       okerror(tag, metamap) <- z,
      ...>       %{a: val} = metamap do
      ...>         "We have: \#{res} \#{res2} \#{tag} \#{val}"
      ...>   else
      ...>       _ -> "Failure"
      ...>   end
      "We have: 10 33 ok 42"

  Note that for `ok()` and `error()`, the first argument will match the first element after the `:ok` or `:error` tag.
  On the other hand, for `okerror()`, the first argument will match the tag `:ok` or `:error`.


  Note: It is not required to import Solution to use the macros inside `swith` without prefixing them.
  """
  defmacro swith(statements, conditions)

  defmacro swith(statement, conditions) do
    do_swith([statement], conditions, __CALLER__)
  end

  # Since `swith` is a normal macro bound to normal function rules,
  # define it for all possible arities.
  for arg_num <- 1..252 do
    args = 0..arg_num |> Enum.map(fn num -> Macro.var(:"statement#{num}", __MODULE__) end)
    @doc false
    defmacro swith(unquote_splicing(args), conditions) do
      do_swith(unquote(args), conditions, __CALLER__)
    end
  end

  defp do_swith(statements, conditions, caller_env) do
    guard_env = Map.put(__ENV__, :context, :guard)

    statements =
      statements
      |> Enum.flat_map(fn node ->
        case node do
          {:<-, meta, [lhs, rhs]} ->
            {lhs, extra_statements} = expand_match(lhs, [])
            lhs = Macro.expand(lhs, guard_env)
            node = {:<-, meta, [lhs, rhs]}

            [node | extra_statements]

          other ->
            [Macro.expand(other, caller_env)]
        end
      end)

    quote do
      with(unquote_splicing(statements), unquote(conditions))
    end
  end

  @doc """
  Changes an `:ok` into an `:error`, an `{:ok, ...}` into an `{:error, ...}` and vice-versa.


      iex> invert_okerror(:ok)
      :error
      iex> invert_okerror({:ok, 1,2,3})
      {:error, 1,2,3}
      iex> invert_okerror({:error, "failure"})
      {:ok, "failure"}
      iex> invert_okerror("improper datatype")
      ** (ArgumentError) argument error
  """
  def invert_okerror(okerror) do
    case okerror do
      :ok ->
        :error

      :error ->
        :ok

      x when is_ok(x, 1) ->
        x
        |> Tuple.delete_at(0)
        |> Tuple.insert_at(0, :error)

      x when is_error(x, 1) ->
        x
        |> Tuple.delete_at(0)
        |> Tuple.insert_at(0, :ok)

      _ ->
        raise ArgumentError
    end
  end

  @doc """
  Turns a nillable type (that can be either `nil` or a non-nil value) into an ok/error tuple.

  Also handles Erlang's 'nil'-type equivalent: the atom `:undefined`.

      iex> from_nillable(nil)
      {:error, nil}
      iex> from_nillable(42)
      {:ok, 42}
      iex> (%{a: "yes!"} |> Map.get(:a) |> from_nillable())
      {:ok, "yes!"}
      iex> (%{a: "yes!"} |> Map.get(:b) |> from_nillable())
      {:error, nil}
      iex> from_nillable(:undefined)
      {:error, :undefined}
  """
  def from_nillable(thing) do
    case thing do
      nil ->
        {:error, nil}

      :undefined ->
        {:error, :undefined}

      _ ->
        {:ok, thing}
    end
  end
end
