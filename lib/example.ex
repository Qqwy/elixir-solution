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

  def simple_with(x) do
    swith ok() <- x do
      "X has the value "
      else
        _ -> "X is not a tuple"
    end
  end

  def compound_with(x, y) do
    swith ok(res) <- x,
      ok(res2) <- y do
      "We have: #{res} #{res2}"
    else
      _ -> "Failure"
    end
  end

  def compound_with3(x, y, z) do
    swith ok(res) <- x,
      ok(res2) <- y,
      ok() <- z do
      "We have: #{res} #{res2}"
    else
      _ -> "Failure"
    end
  end

end
