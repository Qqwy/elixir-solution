![Solution](brand/logo_text.png)

`Solution` is a library to help you with working with ok/error-tuples by exposing special matching macros.

[![hex.pm version](https://img.shields.io/hexpm/v/solution.svg)](https://hex.pm/packages/solution)
[![Build Status](https://travis-ci.org/Qqwy/elixir_solution.svg?branch=master)](https://travis-ci.org/Qqwy/elixir_solution)
[![Inline docs](http://inch-ci.org/github/qqwy/elixir_solution.svg)](http://inch-ci.org/github/qqwy/elixir_solution)


## Installation

You can install Solution by adding `solution` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:solution, "~> 0.1.0"}
  ]
end
```

## Examples

The following example snippets pretend that you ran 
```elixir
require Solution
import Solution
```

(although of course, `Solution` is also fully usable without importing it.)

### Guards

`Solution` exposes three guard-safe functions: `is_ok(x)`, `is_error(x)` and `is_okerror(x)`

`ok(x)` will match `:ok`, `{:ok, _}`, `{:ok, _, _}`, `{:ok, _, _, __}` and any longer tuple whose first element is `:ok`.
`error(x)` will match `:error`, `:undefined` `{:error, _}`, `{:error, _, _}`, `{:error, _, _, __}` and any longer tuple whose first element is `:error`.
- `okerror(x)` matches both of these.

Solution also exposes versions of these that take a 'minimum-length' as second argument. A length of `0` works jus the same as above versions. Longer lengths only match tuples that have at least that many elements (as well as starting with the appropriate tag).

### SCase

`Solution.scase`works like a normal `case`-statement,
but will expand `ok()`, `error()` and `okerror()`macros to the left side of `->`.

```elixir
iex> scase {:ok, 10} do
...>  ok() -> "Yay!"
...>  _ -> "Failure"
...>  end
"Yay!"
```


You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
to be used inside the case expression:

```elixir
iex> scase {:ok, "foo", 42} do
...> ok(res, extra) ->
...>      "result: \#{res}, extra: \#{extra}"
...>      _ -> "Failure"
...>    end
"result: foo, extra: 42"
```

Note that for `ok()` and `error()`, the first argument will match the first element after the `:ok` or `:error` tag.
On the other hand, for `okerror()`, the first argument will match the tag `:ok` or `:error`.

### SWith

Works like a normal `with`-statement,
but will expand `ok()`, `error()` and `okerror()` macros to the left side of `<-`.


```elixir
iex> x = {:ok, 10}
iex> y = {:ok, 33}
iex> swith ok(res) <- x,
...>    ok(res2) <- y do
...>      "We have: \#{res} \#{res2}"
...>    else
...>      _ -> "Failure"
...>  end
"We have: 10 33"
```


You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
to be used inside the rest of the `swith`-expression:

```elixir
iex> x = {:ok, 10}
iex> y = {:error, 33}
iex> z = {:ok, %{a: 42}}
iex> swith ok(res) <- x,
...>     error(res2) <- y,
...>     okerror(tag, metamap) <- z,
...>     %{a: val} = metamap do
...>       "We have: \#{res} \#{res2} \#{tag} \#{val}"
...>   else
...>       _ -> "Failure"
...>   end
"We have: 10 33 ok 42"
```

Note that for `ok()` and `error()`, the first argument will match the first element after the `:ok` or `:error` tag.
On the other hand, for `okerror()`, the first argument will match the tag `:ok` or `:error`.


## Documentation

Full documentation can be found at [https://hexdocs.pm/solution](https://hexdocs.pm/solution).


## Changelog

- 0.1.0 - Initial version

