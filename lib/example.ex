defmodule Bar do
  require Solution
  import Solution
  def foo(x) do
    scase x do
      ok(res, res2) -> "Wooh! #{res}, #{res2}"
      x when is_ok(x, 3) -> "Yay"
      _ -> "Fail"
    end
  end

  def bar(x) do
    swith ok() <- x do
      "X has the value"
      else
        _ -> "X is not a tuple"
    end
  end
end
