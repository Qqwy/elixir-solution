![Solution](https://raw.githubusercontent.com/Qqwy/elixir_solution/master/brand/logo_text.png)

`Solution` is a library to help you with working with ok/error-tuples in `case` and `with`-expressions by exposing special matching macros, as well as some extra helper functions.

[![hex.pm version](https://img.shields.io/hexpm/v/solution.svg)](https://hex.pm/packages/solution)
[![Build Status](https://travis-ci.org/Qqwy/elixir-solution.svg?branch=master)](https://travis-ci.org/Qqwy/elixir-solution)[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/solution/index.html)
[![Inline docs](http://inch-ci.org/github/qqwy/elixir_solution.svg)](http://inch-ci.org/github/qqwy/elixir_solution)


## Installation

You can install Solution by adding `solution` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:solution, "~> 0.2.0"}
  ]
end
```

## Rationale

`ok/error` tuples, which are also known by [many other names](https://elixirforum.com/t/names-for-monadic-modalities/17186/5?u=qqwy) some common ones being 'Tagged Status' tuples, 'OK tuples', 'Success Tuples', 'Result tuples', 'Elixir Maybes'.

Working with these types is however a bit complicated, since functions of different libraries (including different approaches in the Elixir standard library and the Erlang standard library) indicate a successful or failure result, in practice, in one of the following formats:

- `{:ok, val}` when everything went well
- `{:error reason}` when there was a failure.
- `:ok`, when everything went well but there is no useful return value to share.
- `:error`, when there was a failure bht there is no useful return value to share.
- `{:ok, val, extra}` ends up being used by some libraries that want to return two things on success.
- `{:error, val, extra}` ends up being used by some libraries that want to return two things on failure.
- In general, `{:ok, ...}` or `{:error, ...}` with more elements have seen some (albeit luckily limited) use.

Clearly, a simple pattern match does not cover all of these cases. This is where `Solution` comes in:

1. It defines clever guard macros that match either of these groups (`Solution.is_ok/1`, `Solution.is_error/1`, `Solution.is_okerror/1`)
2. It defines macros to be used inside special `case` and `with` statements that use these guards and are also able to bind variables:

For instance, you might use `Solution.ok/0` to match any ok-type datatype, and `Solution.error/0` to match any error-type datatype.
But they will also bind variables for you: So you can use `ok(x)` to bind `x = 42` regardless of whether `{:ok, 42}`, `{:ok, 42, "foo"}` or `{:ok, 42, 3,1,4,1,5,9,2,6,5}` was passed. Higher-arity forms like `ok(x, y, z)` also exist.

## Examples

The following example snippets assume that you run 
```elixir
require Solution
import Solution
```

(although of course, `Solution` is also fully usable without importing it.)

### Guards

`Solution` exposes three guard-safe functions: `is_ok(x)`, `is_error(x)` and `is_okerror(x)`

- `Solution.is_ok/1` will match `:ok`, `{:ok, _}`, `{:ok, _, _}`, `{:ok, _, _, __}` and any longer tuple whose first element is `:ok`.
- `Solution.is_error/1` will match `:error`,  `{:error, _}`, `{:error, _, _}`, `{:error, _, _, __}` and any longer tuple whose first element is `:error`.
- `Solution.is_okerror/1` matches both of these.

Solution also exposes versions of these that take a 'minimum-length' as second argument. A length of `0` works jus the same as above versions. Longer lengths only match tuples that have at least that many elements (as well as starting with the appropriate tag).

### SCase

`Solution.scase/2`works like a normal `case`-statement,
but will expand `ok()`, `error()` and `okerror()`macros to the left side of `->`.

```elixir
 scase {:ok, 10} do
  ok() -> "Yay!"
  _ -> "Failure"
  end
#=> "Yay!"
```


You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
to be used inside the case expression:

```elixir
 scase {:ok, "foo", 42} do
 ok(res, extra) ->
      "result: \#{res}, extra: \#{extra}"
      _ -> "Failure"
    end
#=> "result: foo, extra: 42"
```

Note that for `ok(...)` and `error(...)`, the first argument will match the first element after the `:ok` or `:error` tag.
On the other hand, for `okerror(...)`, the first argument will match the tag `:ok` or `:error`.

### SWith

`Solution.swith/2` works like a normal `with`-statement,
but will expand `ok()`, `error()` and `okerror()` macros to the left side of `<-`.


```elixir
 x = {:ok, 10}
 y = {:ok, 33}
 swith ok(res) <- x,
       ok(res2) <- y do
      "We have: \#{res} \#{res2}"
    else
      _ -> "Failure"
  end
#=> "We have: 10 33"
```


You can also pass arguments to `ok()`, `error()` or `okerror()` which will then be bound and available
to be used inside the rest of the `swith`-expression:

```elixir
 x = {:ok, 10}
 y = {:error, 33}
 z = {:ok, %{a: 42}}
 swith ok(res) <- x,
       error(res2) <- y,
       okerror(tag, metamap) <- z,
     %{a: val} = metamap do
       "We have: \#{res} \#{res2} \#{tag} \#{val}"
   else
       _ -> "Failure"
   end
#=> "We have: 10 33 ok 42"
```

Note that for `ok(...)` and `error(...)`, the first argument will match the first element after the `:ok` or `:error` tag.
On the other hand, for `okerror(...)`, the first argument will match the tag `:ok` or `:error`.

### Converting from Nillable types

When functions return a value that can never be the atom `nil`, they often represent error by returning `nil`.
Erlang also has its own equivalent of `nil` that is used in many places in the Erlang standard library and other Erlang libraries: `:undefined`.

`Solution.from_nillable/1` can be used to convert these types into either `{:ok, thing}` if `thing` is  `nil` nor `:undefined`, and into `{:error, nil}` or `{:error, :undefined}` otherwise.

### Solution.Enum

The `Solution.Enum` module contains helper functions to work with enumerables of ok/error tuples.


#### `Solution.Enum.combine/1`

Changes a list of oks into `{:ok, list_of_values}`

```elixir
 Solution.Enum.combine([{:ok, 1}, {:ok, "a", %{meta: "this will be dropped"}}, {:ok, :asdf}])
#=> {:ok, [1, "a", :asdf]}
Solution.Enum.combine([{:ok, 1}, {:ok, 2}, {:error, 3}])
#=> {:error, 3}
Solution.Enum.combine([{:ok, 1}, {:ok, 2}, {:error, 3, 4, 5}])
#=> {:error, 3, 4, 5}
```

#### `Solution.Enum.oks/1`


  Returns a list of only all `ok`-type elements in the enumerable.

```elixir
Solution.Enum.oks([{:ok, 1}, {:error, 2}, {:ok, 3}])
#=> [{:ok, 1}, {:ok, 3}]
```

Similarly, there also exists `errors/1`

#### `Solution.Enum.ok_vals/1`

  Returns a list of the values of all `ok`-type elements in the enumerable.
  
```elixir
Solution.Enum.ok_vals([{:ok, 1}, {:ok, 2,3,4,5}])
#=> [1, 2]
```

Similarly, there also exists `Solution.Enum.error_vals/1`, as well as `Solution.Enum.ok_valstuples/1` and `Solution.Enum.error_valstuples/1`.



## Documentation

Full documentation can be found at [https://hexdocs.pm/solution](https://hexdocs.pm/solution).


## Changelog

- 1.0.0 - Release of stable version. No API changes since last version.
- 0.2.1 - Proper handling of `:undefined` (like `nil`).
- 0.2.0 - the `Solution.Enum` module was added
- 0.1.0 - Initial version

