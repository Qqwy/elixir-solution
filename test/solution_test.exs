defmodule SolutionTest do
  use ExUnit.Case
  use ExUnitProperties

  import Solution
  require Solution

  doctest Solution

  def ok_generator do
    StreamData.one_of([
      :ok,
      StreamData.list_of(StreamData.term())
      |> StreamData.map(fn list -> :erlang.list_to_tuple([:ok | list]) end)
    ])
  end

  def error_generator do
    StreamData.one_of([
      :error,
      StreamData.list_of(StreamData.term())
      |> StreamData.map(fn list -> :erlang.list_to_tuple([:error | list]) end)
    ])
  end

  def okerror_generator do
    StreamData.one_of([ok_generator(), error_generator()])
  end

  describe "scase" do
    property "All ok-type tuples are accepted by ok()" do
      check all okval <- ok_generator() do
        res =
          scase okval do
            ok() -> true
            _ -> false
          end

        assert res == true
      end
    end

    property "All error-type tuples are accepted by error()" do
      check all errval <- error_generator() do
        res =
          scase errval do
            ok() -> false
            error() -> true
            _ -> :failure
          end

        assert res == true
      end
    end

    property "All okerror-type tuples are accepted by okerror()" do
      check all okerrval <- okerror_generator() do
        res =
          scase okerrval do
            okerror() -> true
            _ -> false
          end

        assert res == true
      end
    end
  end

  describe "swith" do
    property "All ok-type tuples are accepted by ok()" do
      check all okval <- ok_generator() do
        res =
          swith ok() <- okval do
            true
          else
            _ -> false
          end

        assert res == true
      end
    end

    property "All error-type tuples are accepted by error()" do
      check all errval <- error_generator() do
        res =
          swith error() <- errval do
            true
          else
            _ -> false
          end

        assert res == true
      end
    end

    property "All okerror-type tuples are accepted by okerror()" do
      check all okerrval <- okerror_generator() do
        res =
          swith okerror() <- okerrval do
            true
          else
            res -> res
          end

        assert res == true
      end
    end
  end
end
